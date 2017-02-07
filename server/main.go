package main

import (
	"crypto/rand"
	"encoding/gob"
	"fmt"
	"github.com/codegangsta/negroni"
	"github.com/goincremental/negroni-sessions"
	"github.com/goincremental/negroni-sessions/redisstore"
	"github.com/gorilla/mux"
	"github.com/mholt/binding"
	"github.com/unrolled/render"
	"net/http"
	//"reflect"
	"strconv"
	"strings"
)

type DecodingBoard struct {
	ColouredPegs   []string
	IndicatorPegs  map[string]int
	Rows           int
	CodeHoles      int
	IndicatorHoles int
}

var DefaultConfig = DecodingBoard{
	ColouredPegs:   []string{"red", "yellow", "green", "blue", "orange", "purple"},
	IndicatorPegs:  map[string]int{"correct": 0, "close": 0},
	Rows:           10,
	CodeHoles:      4,
	IndicatorHoles: 4,
}

type GameData struct {
	Secret []string
}

type Play struct {
	Secret         []string
	GuessCount     int
	Guess          []string
	LastGuessCount int
	Indicator      map[string]int
}

type PlayResponse struct {
	Found      bool           `json: found`
	TotalGuess int            `json: totalGuess`
	Indicator  map[string]int `json: indicator`
	History    []History      `json: history`
}

type History struct {
	Guess     []string       `json: guess`
	Indicator map[string]int `json: indicator`
}

func (Ply *Play) FieldMap(req *http.Request) binding.FieldMap {
	return binding.FieldMap{
		&Ply.Guess: binding.Field{
			Form: "guess[]",
			Binder: func(fieldName string, formVals []string, errs binding.Errors) binding.Errors {
				Ply.LastGuessCount = 0
				for i, value := range strings.Split(formVals[0], ",") {
					if i < DefaultConfig.CodeHoles {
						Ply.Guess[i] = strings.ToLower(value)
						Ply.LastGuessCount++
					}
				}
				return errs
			},
			Required: true,
		},
	}

}

func Coder(Ply *Play) ([]string, error) {
	Ply.Secret = make([]string, DefaultConfig.CodeHoles)
	Randoms := make([]byte, DefaultConfig.CodeHoles)
	_, err := rand.Read(Randoms)
	if err != nil {
		fmt.Println("error:", err)
		return Ply.Secret, err
	}

	for key, value := range Randoms {
		Ply.Secret[key] = DefaultConfig.ColouredPegs[int(value)%DefaultConfig.CodeHoles]
	}
	return Ply.Secret, err
}

func Checker(Ply *Play) (map[string]int, bool) {

	Secret := make([]string, DefaultConfig.CodeHoles)
	copy(Secret, Ply.Secret)
	Guess := Ply.Guess
	Indicator := Ply.Indicator
	Indicator["correct"] = 0
	Indicator["close"] = 0

	Found := true
	for key, value := range Guess {
		if Secret[key] == value {
			Found = Found && true
			Indicator["correct"] += 1
			Secret[key] = "NULL"
		} else if hasSecret := func(value string) bool {
			for i, current := range Secret {
				if current == value {
					Secret[i] = "NULL"
					return true
				}
			}
			return false
		}; hasSecret(value) {
			Found = Found && false
			Indicator["close"] += 1
		} else {
			Found = Found && false
		}

	}
	return Ply.Indicator, Found
}

var r *render.Render
var store, _ = redisstore.New(10, "tcp", ":6379", "", []byte("secret123"))

func main() {
	gob.Register(map[string]int{})

	//var config = DefaultConfig
	//fmt.Println(config.CodeHoles)
	//fmt.Println(config.IndicatorPegs[1])

	//	Render
	r = render.New(render.Options{
		IndentJSON: true,
	})

	//	Routing
	router := mux.NewRouter()
	//	router.Methods("GET", "POST")
	router.HandleFunc("/", HomeHandler)
	router.HandleFunc("/register", RegisterGetHandler).Methods("GET")
	router.HandleFunc("/play", PlayPostHandler).Methods("POST")

	//	Negroni
	n := negroni.Classic()

	n.Use(sessions.Sessions("mastermind_", store))

	n.UseHandler(router)

	n.Run(":3000")

}

func HomeHandler(w http.ResponseWriter, req *http.Request) {
	r.JSON(w, http.StatusOK, map[string]string{
		"message": "Welcome to MasterMind!",
		"play":    "Wanna play MasterMind? Go to -> /register",
	})

}

func RegisterGetHandler(w http.ResponseWriter, req *http.Request) {

	session, err := store.Get(req, "mastermind_")
	if err != nil {
		panic(err)
	}
	Ply := new(Play)
	session.Options.MaxAge = 3600
	session.Values["GuessCount"] = 0
	session.Values["Secret"], _ = Coder(Ply)
	if err := session.Save(req, w); err != nil {
		panic(err)
	}

	r.JSON(w, http.StatusOK, map[string]string{
		"message": "You are on the point of play!",
		"to_play": "Just POST your guess to -> /play",
	})
}

func PlayPostHandler(w http.ResponseWriter, req *http.Request) {

	session, err := store.Get(req, "mastermind_")
	if err != nil {
		panic(err)
	}

	GuessCount, found := session.Values["GuessCount"]
	if !found || GuessCount == "" {
		r.JSON(w, http.StatusOK, map[string]string{
			"message": "You have to register to server than you can play here",
			"to_play": "Go to -> /register",
		})
	} else {

		Ply := new(Play)
		Ply.GuessCount = GuessCount.(int)

		Ply.Secret = make([]string, DefaultConfig.CodeHoles)
		Ply.Guess = make([]string, DefaultConfig.CodeHoles)
		Ply.Indicator = make(map[string]int, DefaultConfig.IndicatorHoles)

		Ply.Secret = session.Values["Secret"].([]string)

		fmt.Println(Ply.Secret)
		errs := binding.Bind(req, Ply)
		if errs.Handle(w) {
			return
		}
		if Ply.LastGuessCount < DefaultConfig.CodeHoles {
			r.JSON(w, http.StatusOK, map[string]string{
				"error": "You have to push " + strconv.Itoa(DefaultConfig.CodeHoles) + " colour in your code.",
			})
		} else {

			Ply.GuessCount++
			var Found bool
			Ply.Indicator, Found = Checker(Ply)
			fmt.Println(Ply.Indicator)

			session.Values[Ply.GuessCount] = Ply.Guess
			session.Values[Ply.GuessCount+10] = Ply.Indicator
			session.Values["GuessCount"] = Ply.GuessCount

			if err := session.Save(req, w); err != nil {
				panic(err)
			}

			PlyResponse := new(PlayResponse)
			PlyResponse.Found = Found
			PlyResponse.TotalGuess = Ply.GuessCount
			PlyResponse.Indicator = Ply.Indicator
			PlyResponse.History = make([]History, Ply.GuessCount)
			for i := 0; i < Ply.GuessCount; i++ {
				PlyResponse.History[i].Guess = session.Values[i+1].([]string)
				PlyResponse.History[i].Indicator = session.Values[i+11].(map[string]int)
			}
			r.JSON(w, http.StatusOK, PlyResponse)

			fmt.Println(Found)
			fmt.Println(Ply.GuessCount)
			if Found || Ply.GuessCount == 10 {
				session.Options.MaxAge = -1
				if err := session.Save(req, w); err != nil {
					panic(err)
				}
			}

		}
	}
}
