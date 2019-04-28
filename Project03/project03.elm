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

type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | UsernameUpdate String
         | PasswordUpdate String

type alias Model = { score: Int
                   , player:Player
                   , apple:Apple
                   ,enemies:Enemies
                   ,direction:Direction
                   ,state:GameStates
                   , status: GameStatus
                   , winMessage: String
                   ,username : String
                   ,password : String }

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
      }
  in ( model,  Cmd.none ) -- add init model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
                     Tick time (keystate, (x,y) , _) ->
                       if (hitEnemies model.player model.enemies)
                         then ({model | player = (updatePlayer model.player (round x,round y)), enemies = []},Cmd.none)
                         else ({model | player = (updatePlayer model.player (round x,round y)), enemies = (updateEnemies model.enemies)},Cmd.none)



                     MakeRequest req    -> (model,Cmd.none)
                     UrlChange url      -> (model,Cmd.none)
                     UsernameUpdate newname -> ({model | username = newname} ,Cmd.none)
                     PasswordUpdate newpass -> ({model | password = newpass} ,Cmd.none)

view : Model -> { title : String, body : Collage Msg }
view model = let
                title = "Apple Dodge"
                body = collage 250 300 elements
                elements = case model.state of
                                Game -> gameElements
                                Login -> signinElements
                                SignUp -> signinElements

                gameElements = [startElements ] ++ appleElement ++ playerElement ++ enemiesElement ++ [playerPos] ++ [enemiesPos]
                startElements = group [background]
                appleElement = [drawApple model.apple]
                playerElement = [drawPlayer model.player]
                enemiesElement = drawEnemies model.enemies
                background = rectangle 200 200
                              |> filled black
                playerPos = GraphicSVG.text ( playerToString model.player )
                            |> filled white
                            |> move (0,50)
                enemiesPos = GraphicSVG.text (enemiesToString model.enemies)
                            |> filled white
                            |> move (0,-50)

                signinElements = [signinBackground, signinText] ++ usernameInput ++ passwordInput ++ signinButton
                signinBackground = rectangle 200 200
                            |> filled grey
                signinText = GraphicSVG.text "Login" |> filled black |> move (0,50)
                usernameInput = [html 200 200 (div [] [input [placeholder "Username", onInput UsernameUpdate, value model.username] []])|> move (-100,0)]
                passwordInput = [html 200 200 (div [] [input [type_ "password" ,placeholder "Password", onInput PasswordUpdate, value model.password] []]) |> move (-100,-30)]
                signinButton = [html 200 200 ( div [] [button [] [Html.text "Sign In"]])|> move (-100,-70)]
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
