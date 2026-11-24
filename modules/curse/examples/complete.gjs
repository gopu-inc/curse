import curse

muts count = [0]

lt title = curse::label("Curse — compteur interactif")
lt count_view = curse::label("Valeur : 0")
lt decrement = curse::button("-1")
lt increment = curse::button("+1")
lt reset = curse::button("Remettre à zéro")
lt name = curse::input("Ton nom")
lt greet = curse::button("Dire bonjour")
lt message = curse::label("Entre ton nom puis active Dire bonjour.")
lt help = curse::label("Tab : changer de contrôle | Entrée/Espace : activer | q : quitter")

lt root = curse::column([
    title,
    count_view,
    curse::row([decrement, increment, reset]),
    name,
    greet,
    message,
    help
])

fn on_event(event, root): bool {
    if (event[0] != "key") { ret true }

    lt key = event[1]
    if (key == 113 && !curse::input_focused(root)) { ret false }

    if ((key == 13 || key == 32) && !curse::input_focused(root)) {
        if (curse::is_focused(decrement)) {
            count[0] = count[0] - 1
        } else if (curse::is_focused(increment)) {
            count[0] = count[0] + 1
        } else if (curse::is_focused(reset)) {
            count[0] = 0
        } else if (curse::is_focused(greet)) {
            lt entered_name = curse::value(name)
            if (entered_name == "") {
                message[1] = "Le champ nom est vide."
            } else {
                message[1] = "Bonjour, " + entered_name + " !"
            }
        }
        count_view[1] = "Valeur : " + ("" + count[0])
    }

    ret true
}

curse::run(root, on_event)
