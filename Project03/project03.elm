import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import String
import Html exposing (..)
import Http
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JDecode
import Json.Encode as JEncode

--rootUrl ="http://localhost:8000/e/kaya6/"



rootUrl = "https://mac1xa3.ca/e/kaya6/"

type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | UsernameUpdate String
         | PasswordUpdate String
         | SigninButtonPressed
         | GotLoginResponse (Result Http.Error String)
         | SignupPageSwtich
         | SignupButtonPressed
         | GotSignupResponse (Result Http.Error String)

type alias Model = { score: Int
                   , player:Player
                   , apple:Apple
                   ,enemies:Enemies
                   ,direction:Direction
                   ,state:GameStates
                   , status: GameStatus
                   , winMessage: String
                   ,username : String
                   ,password : String
                   ,error : String}

type alias Direction = (Int, Int)
type alias Player = (Int, Int)
type alias Enemies = List (Int, Int, Direction)
type alias Apple = (Int, Int)

type GameStates = Login
                 | SignUp
                 | Game
type GameStatus = Start
                | Ongoing
                | Finished


init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
  let
    model =
      {
      score = 0
      , player = (30,30)
      , apple = (0,0)
      , enemies = [(0,0,(-1,1))]
      , direction = (0,0)
      , status = Ongoing
      ,state = Login
      , winMessage = ""
      , username = ""
      , password = ""
      , error = ""
      }
  in ( model,  Cmd.none ) -- add init model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
                     Tick time (keystate, (x,y) , _) ->
                       if (hitEnemies model.player model.enemies)
                         then ({model | player = (100000000000,100000000000)},Cmd.none)
                         else if (getApple model.player model.apple)
                           then ({model | player = (updatePlayer model.player (round x,round y)), enemies = (updateEnemies model.enemies), score = model.score+1, apple = (1000,1000)},Cmd.none)
                         else ({model | player = (updatePlayer model.player (round x,round y)), enemies = (updateEnemies model.enemies)},Cmd.none)


                     MakeRequest req    -> (model,Cmd.none)
                     UrlChange url      -> (model,Cmd.none)
                     UsernameUpdate newname -> ({model | username = newname} ,Cmd.none)
                     PasswordUpdate newpass -> ({model | password = newpass} ,Cmd.none)
                     SigninButtonPressed -> (model , signinPost model )
                     GotLoginResponse result ->
                          case result of
                              Ok "LoginFailed" ->
                                  ( { model | error = "failed to login" }, Cmd.none )

                              Ok _ ->
                                  ( {model | state = Game}, Cmd.none )

                              Err error ->
                                  ( handleError model error, Cmd.none )
                     SignupPageSwtich ->  ({model | state = SignUp}, Cmd.none )
                     SignupButtonPressed -> (model , signupPost model )
                     GotSignupResponse result ->
                          case result of
                              Ok "LoggedIn" ->
                                  ( { model | error = "Signup Success" }, Cmd.none )

                              Ok _ ->
                                  ( {model | error = "Signup Failure"}, Cmd.none )

                              Err error ->
                                  ( handleError model error, Cmd.none )

view : Model -> { title : String, body : Collage Msg }
view model = let
                title = "Apple Dodge"
                body = collage 250 300 elements
                elements = case model.state of
                                Game -> gameElements
                                Login -> signinElements
                                SignUp -> signupElements

                gameElements = [startElements ] ++ appleElement ++ playerElement ++ enemiesElement ++ [scoreText]
                startElements = group [background]
                appleElement = [drawApple model.apple]
                playerElement = [drawPlayer model.player]
                enemiesElement = drawEnemies model.enemies
                scoreText = GraphicSVG.text ( "Score: " ++ (String.fromInt model.score))
                            |> filled black
                            |> move (-20, 105)
                background = rectangle 200 200
                              |> filled black


                signinElements = [signinBackground, signinText, errorText] ++ usernameInput ++ passwordInput ++ signinButton ++ goTosignup
                signinBackground = rectangle 200 200
                            |> filled grey
                signinText = GraphicSVG.text "Login" |> filled black |> move (-15,50)
                errorText = GraphicSVG.text model.error |> filled black |> move (-15,70)
                usernameInput = [html 200 200 (div [] [input [placeholder "Username", onInput UsernameUpdate, value model.username] []])|> move (-85,30)]
                passwordInput = [html 200 200 (div [] [input [type_ "password" ,placeholder "Password", onInput PasswordUpdate, value model.password] []]) |> move (-85,0)]
                signinButton = [html 200 200 ( div [] [button [Html.Events.onClick SigninButtonPressed] [Html.text "Sign In"]])|> move (-85,-40)]
                goTosignup = [html 200 200 ( div [] [button [Html.Events.onClick SignupPageSwtich] [Html.text "Go To Signup"]])|> move (-85,-70)]

                signupElements = [signinBackground, signupText] ++ usernameInput ++ passwordInput ++ signupButton
                signupText = GraphicSVG.text "Register" |> filled black |> move (-15,50)
                signupButton = [html 200 200 ( div [] [button [Html.Events.onClick SignupButtonPressed] [Html.text "Sign Up"]])|> move (-85,-40)]
             in { title = title , body = body }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : AppWithTick () Model Msg
main = appWithTick Tick
       { init = init
       , update = update
       , view = view
       , subscriptions = subscriptions
       , onUrlRequest = MakeRequest
       , onUrlChange = UrlChange
       }



updatePlayer: Player -> Direction -> Player
updatePlayer (a,b) (c,d) = (a+c,b+d)

drawPlayer : Player -> Shape userMsg
drawPlayer player = case player of
              (a,b) -> circle 5
                       |> filled green
                       |> move (toFloat a, toFloat b)


drawApple : Apple -> (Shape userMsg)
drawApple apple = case apple of
                  (a,b) -> circle 3
                           |> filled red
                           |> move (toFloat a,toFloat b)

drawEnemies : Enemies -> List (Shape userMsg)
drawEnemies enemies = case enemies of
                      ((a,b,c)::xs)-> [circle 4
                                |> filled blue
                                |> move (toFloat a,toFloat b)] ++ drawEnemies xs
                      [] -> []
updateEnemies : Enemies -> Enemies
updateEnemies enemies = case enemies of
                        ((a,b,(c,d))::xs) ->
                          if a == 100 then
                            if b == 100 then [(a-3,b-3,(-c,-d))] ++ updateEnemies xs else if b == (-100) then [(a-(3),b+(3),(-c,-d))] ++ updateEnemies xs else [(a-(3),b+(d),(-c, d))] ++ updateEnemies xs

                          else if a == (-100) then
                             if b == 100 then [(a+(3),b-(3),(-c,-d))] ++ updateEnemies xs else if b == (-100) then [(a+(3),b+(3),(-c,-d))] ++ updateEnemies xs else [(a+(3),b+(d),(-c, d))] ++ updateEnemies xs
                          else if b == 100 then [(a+(c),b+(3*d),(c,-d))] ++ updateEnemies xs else if b == (-100) then [(a+(c),b+(3*d),(c,-d))] ++ updateEnemies xs else [(a+(c),b+(d),(c, d))] ++ updateEnemies xs


                        [] -> []
getApple : Player -> Apple -> Bool
getApple (a,b) (c,d) = ((c-a)^2) + ((b-d)^2) <= 64

hitEnemies : Player -> Enemies -> Bool
hitEnemies (a,b) z = case z of
                      ((c,d,e)::xs) -> ((((c-a)^2) + ((b-d)^2) <= 64)) && (hitEnemies (a,b) xs)
                      [] -> True
playerToString : Player -> String
playerToString (a,b) = String.fromInt(a) ++ ", " ++ String.fromInt(b)

enemiesToString : Enemies -> String
enemiesToString l  = case l of
                     ((a,b,c)::xs)-> String.fromInt(a) ++ ", " ++ String.fromInt(b) ++ "; " ++ (enemiesToString xs)
                     [] -> ""

--Django
passwordEncoder : Model -> JEncode.Value
passwordEncoder model =
    JEncode.object
        [ ( "username"
          , JEncode.string model.username
          )
        , ( "password"
          , JEncode.string model.password
          )
        ]

signinPost : Model -> Cmd Msg
signinPost model =
    Http.post
        { url = rootUrl ++ "loginapp/loginuser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotLoginResponse
        }

signupPost : Model -> Cmd Msg
signupPost model =
    Http.post
        { url = rootUrl ++ "loginapp/adduser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotSignupResponse
        }

handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }

        Http.Timeout ->
            { model | error = "timeout" }

        Http.NetworkError ->
            { model | error = "network error" }

        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "bad body " ++ body }
