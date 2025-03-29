module Card exposing (Model, Msg, init, main, update, view)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
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
    , show : Show
    , colors : ZipList Color
    , href : String
    , bestseller : Bool
    , language : Language
    }


type Show
    = Inside
    | Outside


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


decoder : Decoder Model
decoder =
    Decode.succeed ModelRecord
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "description" Decode.string
        |> Pipeline.hardcoded Outside
        |> Pipeline.required "colors" colorListDecoder
        |> Pipeline.required "href" Decode.string
        |> Pipeline.required "bestseller" Decode.bool
        |> Pipeline.required "language" languageDecoder
        |> Decode.map Model


languageDecoder : Decoder Language
languageDecoder =
    Decode.succeed Language
        |> Pipeline.required "code" Decode.string
        |> Pipeline.required "bestseller" Decode.string
        |> Pipeline.required "showInside" Decode.string
        |> Pipeline.required "close" Decode.string


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
    Decode.succeed Color
        |> Pipeline.required "code" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "outsideImage" Decode.string
        |> Pipeline.required "insideImage" Decode.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Error ->
            ( Error, Cmd.none )

        Model modelRecord ->
            case msg of
                ToggleInside ->
                    ( Model { modelRecord | show = flipShow modelRecord.show }
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


flipShow : Show -> Show
flipShow show =
    case show of
        Inside ->
            Outside

        Outside ->
            Inside


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
        [ cardImage model.language model.show (ZipList.current model.colors)
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


cardImage : Language -> Show -> Color -> Html Msg
cardImage language show color =
    Html.figure [ Attr.class <| outsideOrInside show "outside" "inside" ]
        [ Html.button [ Event.onClick ToggleInside ]
            [ Html.text <| outsideOrInside show language.showInside language.close ]
        , Html.img [ Attr.src <| outsideOrInside show color.outsideImage color.insideImage ] []
        ]


outsideOrInside : Show -> a -> a -> a
outsideOrInside show outside inside =
    case show of
        Outside ->
            outside

        Inside ->
            inside


errorView : Html msg
errorView =
    Html.article [ Attr.class "card", Attr.class "error" ] []
