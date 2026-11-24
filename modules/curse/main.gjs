import curse

muts count = [0]
muts ticks = [0]
lt spinner = ["◴", "◷", "◶", "◵"]

lt title = curse::label("╭─ CURSE  /  TERMINAL STUDIO ─────────────────────────────────╮")
lt subtitle = curse::label("  Interface interactive Goscript  •  cible 120 FPS  •  UTF-8")
lt counter = curse::label("  Compteur : 0")
lt decrease = curse::button("−  Diminuer")
lt increase = curse::button("+  Augmenter")
lt reset = curse::button("↺  Réinitialiser")
lt name = curse::input("Écris ton nom…")
lt greet = curse::button("Dire bonjour")
lt status = curse::label("  Prêt. Utilise Tab pour changer de contrôle.")
lt footer = curse::label("  Entrée : activer  ·  Tab : naviguer  ·  q : quitter")
lt pulse = curse::label("  ● En direct")

lt root = curse::column([
    title,
    subtitle,
    counter,
    curse::row([decrease, increase, reset]),
    curse::row([name, greet]),
    status,
    footer,
    pulse
])

fn on_event(event, root): bool {
    if (event[0] == "timeout") {
        ticks[0] = (ticks[0] + 1) % 4
        pulse[1] = "  " + spinner[ticks[0]] + " En direct  ·  cible 120 FPS"
        ret true
    }
    if (event[0] != "key") { ret true }

    lt key = event[1]
    if (key == 113 && !curse::input_focused(root)) { ret false }
    if ((key == 13 || key == 32) && !curse::input_focused(root)) {
        if (curse::is_focused(decrease)) {
            count[0] = count[0] - 1
            status[1] = "  Compteur diminué."
        } else if (curse::is_focused(increase)) {
            count[0] = count[0] + 1
            status[1] = "  Compteur augmenté."
        } else if (curse::is_focused(reset)) {
            count[0] = 0
            status[1] = "  Compteur remis à zéro."
        } else if (curse::is_focused(greet)) {
            lt entered_name = curse::value(name)
            if (entered_name == "") { status[1] = "  Saisis ton nom dans le champ." }
            else { status[1] = "  Bonjour, " + entered_name + " !" }
        }
        counter[1] = "  Compteur : " + ("" + count[0])
    }
    ret true
}

curse::run(root, on_event)
