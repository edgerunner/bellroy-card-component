module Card exposing (Model, Msg, init, main, update, view)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as Decode exposing (Decoder)
import ZipList exposing (ZipList)


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Model ModelRecord
    | Error


type alias ModelRecord =
    { name : String
    , description : String
    , showInside : Bool
    , colors : ZipList Color
    , href : String
    , bestseller : Bool
    , language : Language
    }


type Msg
    = ToggleInside
    | SelectColor Int


type alias Color =
    { code : String
    , name : String
    , outsideImage : String
    , insideImage : String
    }


type alias Language =
    { code : String
    , bestseller : String
    , showInside : String
    , close : String
    }


init : Decode.Value -> ( Model, Cmd Msg )
init =
    Decode.decodeValue decoder
        >> Result.mapError (Debug.log "Decode Error")
        >> Result.withDefault Error
        >> (\model -> ( model, Cmd.none ))


default : Model
default =
    Model
        { name = "Card Title"
        , description = "Card Content"
        , showInside = False
        , colors =
            ZipList.singleton
                { code = "red"
                , name = "Red"
                , outsideImage = "red-outside.png"
                , insideImage = "red-inside.png"
                }
        , href = ""
        , bestseller = False
        , language =
            { code = "en"
            , bestseller = "Bestseller"
            , showInside = "Show Inside"
            , close = "Close"
            }
        }


decoder : Decoder Model
decoder =
    Decode.map7 ModelRecord
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.succeed False)
        (Decode.field "colors" colorListDecoder)
        (Decode.field "href" Decode.string)
        (Decode.field "bestseller" Decode.bool)
        (Decode.field "language" languageDecoder)
        |> Decode.map Model


languageDecoder : Decoder Language
languageDecoder =
    Decode.map4 Language
        (Decode.field "code" Decode.string)
        (Decode.field "bestseller" Decode.string)
        (Decode.field "showInside" Decode.string)
        (Decode.field "close" Decode.string)


colorListDecoder : Decoder (ZipList Color)
colorListDecoder =
    Decode.list colorDecoder
        |> Decode.andThen
            (ZipList.fromList
                >> Maybe.map Decode.succeed
                >> Maybe.withDefault (Decode.fail "color list can't be empty")
            )


colorDecoder : Decoder Color
colorDecoder =
    Decode.map4 Color
        (Decode.field "code" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "outsideImage" Decode.string)
        (Decode.field "insideImage" Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Error ->
            ( Error, Cmd.none )

        Model modelRecord ->
            case msg of
                ToggleInside ->
                    ( Model { modelRecord | showInside = not modelRecord.showInside }
                    , Cmd.none
                    )

                SelectColor index ->
                    ( Model
                        { modelRecord
                            | colors =
                                ZipList.goToIndex index modelRecord.colors
                                    |> Maybe.withDefault modelRecord.colors
                        }
                    , Cmd.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        Model modelRecord ->
            modelView modelRecord

        Error ->
            errorView


modelView : ModelRecord -> Html Msg
modelView model =
    Html.article [ Attr.class "card" ]
        [ cardImage model.language model.showInside (ZipList.current model.colors)
        , Html.h1 [] [ Html.text model.name ]
        , colorSelector model.colors
        , Html.h5 [] [ Html.text model.description ]
        ]


colorSelector : ZipList Color -> Html Msg
colorSelector =
    ZipList.indexedSelectedMap colorButton
        >> ZipList.toList
        >> Html.form []


colorButton : Int -> Bool -> Color -> Html Msg
colorButton index selected color =
    Html.input
        [ Attr.name "color"
        , Attr.type_ "radio"
        , Attr.checked selected
        , Attr.title color.name
        , Attr.value color.code
        , Event.onClick (SelectColor index)
        ]
        []


cardImage : Language -> Bool -> Color -> Html Msg
cardImage language showInside color =
    Html.figure [ Attr.class <| outsideOrInside showInside "outside" "inside" ]
        [ Html.button [ Event.onClick ToggleInside ]
            [ Html.text <| outsideOrInside showInside language.showInside language.close ]
        , Html.img [ Attr.src <| outsideOrInside showInside color.outsideImage color.insideImage ] []
        ]


outsideOrInside : Bool -> a -> a -> a
outsideOrInside showInside outside inside =
    if showInside then
        inside

    else
        outside


errorView : Html msg
errorView =
    Html.article [ Attr.class "card", Attr.class "error" ] []
