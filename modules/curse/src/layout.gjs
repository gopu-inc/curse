pub fn rect(p_left: int, p_top: int, p_width: int, p_height: int): array {
    ret [p_left, p_top, p_width, p_height]
}

pub fn split_horizontal(p_area: array, p_first_width: int): array {
    lt rect_left = p_area[0]
    lt rect_top = p_area[1]
    lt rect_width = p_area[2]
    lt rect_height = p_area[3]
    lt split_width = p_first_width
    if (split_width < 0) { split_width = 0 }
    if (split_width > rect_width) { split_width = rect_width }
    ret [[rect_left, rect_top, split_width, rect_height], [rect_left + split_width, rect_top, rect_width - split_width, rect_height]]
}

pub fn split_vertical(p_area: array, p_first_height: int): array {
    lt rect_left = p_area[0]
    lt rect_top = p_area[1]
    lt rect_width = p_area[2]
    lt rect_height = p_area[3]
    lt split_height = p_first_height
    if (split_height < 0) { split_height = 0 }
    if (split_height > rect_height) { split_height = rect_height }
    ret [[rect_left, rect_top, rect_width, split_height], [rect_left, rect_top + split_height, rect_width, rect_height - split_height]]
}

pub fn center(p_area: array, p_width: int, p_height: int): array {
    lt result_width = p_width
    lt result_height = p_height
    if (result_width < 0) { result_width = 0 }
    if (result_height < 0) { result_height = 0 }
    if (result_width > p_area[2]) { result_width = p_area[2] }
    if (result_height > p_area[3]) { result_height = p_area[3] }
    lt result_left = p_area[0] + (p_area[2] - result_width) / 2
    lt result_top = p_area[1] + (p_area[3] - result_height) / 2
    ret [result_left, result_top, result_width, result_height]
}

pub fn inset(p_area: array, p_top: int, p_right: int, p_bottom: int, p_left: int): array {
    lt left = p_left
    lt top = p_top
    lt right = p_right
    lt bottom = p_bottom
    if (left < 0) { left = 0 }
    if (top < 0) { top = 0 }
    if (right < 0) { right = 0 }
    if (bottom < 0) { bottom = 0 }
    if (left > p_area[2]) { left = p_area[2] }
    if (top > p_area[3]) { top = p_area[3] }
    lt width = p_area[2] - left - right
    lt height = p_area[3] - top - bottom
    if (width < 0) { width = 0 }
    if (height < 0) { height = 0 }
    ret [p_area[0] + left, p_area[1] + top, width, height]
}
