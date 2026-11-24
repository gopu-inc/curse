import curse

lt area = curse::layout::rect(1, 2, 30, 12)
lt inset_area = curse::inset(area, 1, 2, 1, 2)
lt title = curse::widgets::label("package import")
lt frame = curse::screen_create(12, 2)
curse::screen_put_text(frame, 0, 0, "package", 12, -1, -1, 0)
curse::render(title, frame, 0, 1, 12, 1)
lt rendered = curse::screen_build_frame(frame)
if (area[0] == 1 && area[1] == 2 && inset_area[0] == 3 && inset_area[2] == 26 &&
    title[1] == "package import" && rendered != "") {
    print("OK root package import")
} else {
    print("FAIL root package import")
    exit(1)
}
