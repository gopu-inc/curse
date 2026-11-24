# Curse — guide complet

Curse est une bibliothèque d’interface terminal pour Goscript. Elle fournit les
widgets, le focus clavier, les événements, les calculs de layout, le buffer
d’écran et la boucle d’application.

## Importer Curse

Le fichier `__self__.gjs` est le point d’entrée du package. Il expose les
modules complets (`app`, `events`, `layout`, `screen`, `terminal`, `widgets`)
et des raccourcis pour l’API la plus courante. Un programme peut donc commencer
par un seul import :

```goscript
import curse

lt area = curse::rect(0, 0, 80, 24)
lt inner = curse::inset(area, 1, 2, 1, 2)
lt title = curse::label("Mon application")
```

Les appels à plat comme `curse::inset` sont des alias de `layout::inset`.
Goscript appelle les fonctions et sous-modules avec `::` :
`curse::layout::inset(...)`, `curse::widgets::input(...)` ou
`curse::terminal::size()`. Les alias à plat donnent un accès direct aux
fonctions les plus utilisées, par exemple `curse::inset(...)`.

Pour les programmes interactifs, il faut lancer avec le runtime Goscript qui
inclut les primitives `curse_host_*` et avec un terminal POSIX :

```sh
GOSCRIPT_SHARE_DIR=../goscript/lib ../goscript/build/bin/gd main.gjs
```

## Première application

```goscript
import curse

fn on_event(event, root): bool {
    if (event[0] == "key" && event[1] == 113 && !curse::input_focused(root)) {
        ret false
    }
    ret true
}

lt root = curse::column([
    curse::label("Carnet de notes"),
    curse::input("Titre"),
    curse::button("Enregistrer"),
    curse::label("Tab change le focus ; q quitte")
])

curse::run(root, on_event)
```

L’exemple interactif complet avec boutons actifs, champ texte, compteur et
message personnalisé est [`examples/complete.gjs`](../examples/complete.gjs).
Il utilise seulement `import curse` puis les fonctions racine sous la forme
`curse::nom(...)`, sans importer les sous-modules. Lance-le depuis le dépôt :

```sh
GOSCRIPT_SHARE_DIR=../goscript/lib ../goscript/build/bin/gd examples/complete.gjs
```

Le tableau de bord livré avec le paquet se lance aussi comme un module :

```sh
gd -c curse
```

Depuis le répertoire du projet, `sudo golem install --local .` installe le
paquet et ses dépendances dans `/usr/local/share/goscript`, puis crée la
commande `/usr/local/bin/curse`. Le manifeste choisit `main.gjs` avec `entry`
et nomme la commande générée avec `command`.

`run` active le terminal brut et l’écran alternatif, place le focus sur le
premier contrôle, dessine l’interface, puis traite les événements. Le terminal
est restauré lorsque la boucle se termine ou lorsqu’un callback ou rendu lève
une erreur. `q` n’est pas une touche de sortie réservée par Curse : l’exemple
choisit de quitter avec `q` quand un champ de saisie n’a pas le focus. Ctrl+C
produit directement un événement `quit` et arrête la boucle.
La cadence par défaut est de 120 FPS. `curse::app::run_at(root, callback, fps)`
permet de choisir une cadence de 1 à 240 FPS. Les caractères UTF-8 sont
assemblés avant leur insertion dans le champ de saisie.

## Alias courts à la racine

Ces fonctions sont disponibles comme `curse::nom(...)` après `import curse`.

| Fonction | Module source | Description |
|---|---|---|
| `run(root, on_event)` | `app::run` | Lance l’application interactive. |
| `rect(left, top, width, height)` | `layout::rect` | Crée `[x, y, largeur, hauteur]`. |
| `split_horizontal(area, first_width)` | `layout::split_horizontal` | Partage un rectangle gauche/droite. |
| `split_vertical(area, first_height)` | `layout::split_vertical` | Partage un rectangle haut/bas. |
| `center(area, width, height)` | `layout::center` | Centre une zone, limitée à `area`. |
| `inset(area, top, right, bottom, left)` | `layout::inset` | Réduit une zone depuis ses bords. |
| `label(text)` | `widgets::label` | Crée un texte. |
| `button(text)` | `widgets::button` | Crée un bouton visuel focalisable. |
| `input(placeholder)` | `widgets::input` | Crée un champ texte. |
| `column(children)` | `widgets::column` | Empile les enfants verticalement. |
| `row(children)` | `widgets::row` | Dispose les enfants horizontalement. |
| `focus(widget, focused)` | `widgets::focus` | Définit l’état de focus d’un bouton ou champ. |
| `is_focused(widget)` | `widgets::is_focused` | Dit si un bouton ou champ a le focus. |
| `value(widget)` | `widgets::value` | Retourne la valeur d’un champ, sinon `""`. |
| `input_focused(root)` | `widgets::input_focused` | Indique si un champ de l’arbre est focalisé. |
| `focus_first(root)` | `widgets::focus_first` | Focalise le premier bouton/champ. |
| `focus_next(root)` | `widgets::focus_next` | Passe au contrôle suivant, avec retour au premier. |
| `handle_key(root, key_code)` | `widgets::handle_key` | Applique une touche aux contrôles. |
| `handle_text(root, text)` | `widgets::handle_text` | Insère du texte dans le champ focalisé. |
| `render(widget, buffer, x, y, width, height)` | `widgets::render` | Dessine un widget dans un buffer. |
| `poll(timeout_ms)` | `events::poll` | Attend un événement clavier ou terminal. |
| `decode_byte(key_code, timeout_ms)` | `events::decode_byte` | Convertit un octet en événement. |

Les noms racine liés au terminal et au buffer sont préfixés afin d’éviter les
collisions. Les alias disponibles sont `terminal_width`, `terminal_height`,
`terminal_size`, `terminal_start`, `terminal_stop`, `terminal_clear`,
`terminal_show_cursor`, `terminal_hide_cursor`, `terminal_reset_style`,
`terminal_move_to`, `terminal_write`, `terminal_flush`, `terminal_write_frame`,
`terminal_take_resize`, `terminal_truecolor`, `terminal_color256`,
`terminal_unicode`, `terminal_utf8_length`, `terminal_cell_width`,
`terminal_read_byte`, `terminal_read_utf8_char`, `terminal_now_ms`,
`screen_create`, `screen_width`, `screen_height`,
`screen_begin_frame`, `screen_invalidate`, `screen_cell`, `screen_put`,
`screen_put_text`, `screen_build_frame` et `screen_present`. Les mêmes fonctions
sont également regroupées sous les modules documentés ci-dessous.

## Layout

Une zone est un tableau `[x, y, width, height]`. Les dimensions négatives des
splits et de `center` sont ramenées à zéro ; les zones produites restent dans
les limites de la zone donnée.

```goscript
lt whole = curse::rect(0, 0, 80, 24)
lt panes = curse::split_horizontal(whole, 24)
lt sidebar = panes[0]
lt content = panes[1]
lt padded = curse::inset(content, 1, 2, 1, 2)
lt dialog = curse::center(whole, 40, 8)
```

Fonctions disponibles sous `curse::layout` :

- `rect(left, top, width, height)`
- `split_horizontal(area, first_width)`
- `split_vertical(area, first_height)`
- `center(area, width, height)`
- `inset(area, top, right, bottom, left)`

`column` donne la hauteur naturelle aux enfants et les place les uns sous les
autres ; les lignes et colonnes imbriquées sont mesurées récursivement. `row`
partage sa largeur entre ses enfants. Les widgets ne dessinent rien si leur
rectangle a une largeur ou une hauteur nulle. Le rendu texte est écrêté aux
limites de son rectangle.

## Widgets et saisie

Les constructeurs créent des tableaux de widgets. Compose l’arbre avant de
passer sa racine à `run` :

```goscript
lt name = curse::input("Nom")
lt save = curse::button("Sauver")
lt form = curse::column([curse::label("Profil"), name, save])
```

Tab passe au contrôle focalisable suivant. Les champs proposent insertion,
gauche/droite, Home/End, Backspace et Delete. `value(field)` retourne leur texte.
Le bouton affiche le focus, mais l’application définit elle-même son action dans
le callback `on_event`.

Fonctions disponibles sous `curse::widgets` :

- `label(text)`, `button(text)`, `input(placeholder)`
- `row(children)`, `column(children)`
- `focus(widget, focused)`, `value(widget)`, `input_focused(root)`
- `focus_first(root)`, `focus_next(root)`
- `handle_key(root, key_code)`, `handle_text(root, text)`
- `render(widget, buffer, x, y, width, height)`

Le modèle de widget est actuellement basé sur des tableaux Goscript. Préfère les
constructeurs et fonctions ci-dessus aux accès directs aux indices internes.

## Événements et callback

Le callback de `run` a la forme `on_event(event, root)` et doit retourner un
booléen : `true` continue la boucle, `false` l’arrête. La forme de l’événement
est :

```text
[type, key_code, width, height, text]
```

Types :

- `"key"` : touche clavier. `text` vaut le caractère ASCII imprimable ou `""`.
- `"resize"` : dimensions terminal dans `width` et `height`.
- `"timeout"` : aucune touche durant le délai de poll. Le callback est appelé
  pour permettre les animations ou mises à jour périodiques.
- `"quit"` : Ctrl+C. La boucle s’arrête sans appeler le callback.
- `"closed"` : l’entrée terminal est fermée. La boucle s’arrête également.

Codes spéciaux : haut `1001`, bas `1002`, droite `1003`, gauche `1004`, Home
`1005`, End `1006`, Delete `1007`, Page Up `1008`, Page Down `1009`. Les touches
ASCII gardent leur code habituel (`q` vaut `113`). Chaque poll renvoie un nouveau
tableau événement, que le callback peut conserver.

Exemple de callback :

```goscript
fn on_event(event, root): bool {
    if (event[0] == "resize") {
        // event[2] = largeur, event[3] = hauteur
    }
    if (event[0] == "key" && event[1] == 113) { ret false }
    ret true
}
```

API du module `curse::events` : `poll(timeout_ms)` et `decode_byte(key_code,
timeout_ms)`.

## Buffer d’écran

Pour un rendu personnalisé, construis un buffer de cellules et soumets-le au
terminal :

```goscript
lt frame = curse::screen_create(80, 24)
curse::screen_begin_frame(frame)
curse::screen_put_text(frame, 2, 1, "Salut", 20, -1, -1, 0)
curse::screen_present(frame)
```

La largeur est exprimée en cellules terminal, pas en octets. Les caractères
UTF‑8 à largeur nulle ou double sont pris en compte lors du dessin. `begin_frame`
remet le contenu courant à l’état vide ; `present` compare les cellules à la
frame précédente et n’écrit que les différences. Après un changement de
dimensions, crée un buffer neuf ou appelle `curse::screen::invalidate` pour forcer le
prochain rendu.

Le module complet `curse::screen` expose :

- `create(width, height)`, `width(buffer)`, `height(buffer)`
- `begin_frame(buffer)`, `invalidate(buffer)`, `cell(buffer, x, y)`
- `put(buffer, x, y, glyph, foreground, background, attributes, cell_width)`
- `put_text(buffer, x, y, text, max_width, foreground, background, attributes)`
- `build_frame(buffer)`, `present(buffer)`

Couleurs `-1` = couleur terminal par défaut, `0..7` = 8 couleurs de base,
`8..15` = variantes lumineuses, `16..255` = palette 256 couleurs. L’attribut
`1` active le gras ; `0` le désactive.

## Terminal bas niveau

Pour les cas qui ne passent pas par `run`, le module `curse::terminal` expose :

- `width()`, `height()`, `size()`
- `start()`, `stop()` : entrée/sortie du mode interactif et de l’écran alternatif
- `clear()`, `show_cursor()`, `hide_cursor()`, `reset_style()`, `move_to(x, y)`
- `write(text)`, `flush()`, `write_frame(frame)`
- `take_resize()`, `truecolor()`, `color256()`, `unicode()`
- `utf8_length(text, byte_offset)`, `cell_width(text, byte_offset)`
- `read_byte(timeout_ms)` : `-1` pour timeout, valeur inférieure à `-1` pour fermeture
- `read_utf8_char(timeout_ms)` : lit un caractère UTF-8 complet, ou une chaîne vide au timeout

`run` gère le cycle de vie du terminal automatiquement. N’appelle pas `start` ou
`stop` depuis le callback de cette boucle.

Les mêmes fonctions sont disponibles en raccourcis `curse::terminal_width()`,
`curse::terminal_size()`, `curse::terminal_start()`, `curse::terminal_stop()`,
`curse::terminal_clear()`, `curse::terminal_move_to(...)`, `curse::terminal_write(...)`,
`curse::terminal_flush()`, `curse::terminal_truecolor()`,
`curse::terminal_color256()` et `curse::terminal_unicode()`.

## Limites connues

- Les événements souris, les fenêtres défilantes, les contraintes de layout
  flexibles, les styles riches et la gestion complète des graphèmes emoji ne sont
  pas encore disponibles.
- Le décodeur couvre les touches de navigation et les variantes CSI courantes ;
  la prise en charge dépend aussi des séquences envoyées par le terminal.

## Développement

Depuis le dépôt Curse, `make test` lance les vérifications non interactives avec
le Goscript local. L’exemple complet se trouve dans `examples/minimal.gjs`.
