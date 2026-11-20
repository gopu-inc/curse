import curse

lt area = curse::layout::rect(1, 2, 30, 12)
lt title = curse::widgets::label("package import")
if (area[0] == 1 && area[1] == 2 && title[1] == "package import") {
    print("OK root package import")
} else {
    print("FAIL root package import")
    exit(1)
}
