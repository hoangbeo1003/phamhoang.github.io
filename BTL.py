import json
import os

DATA_FILE = 'school_data.json'

def tai_du_lieu():
    if not os.path.exists(DATA_FILE):
        return {"classes": [], "teachers": [], "students": []}
    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def lua_du_lieu(data):
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

def them_lop(data):
    lop_id = input("Mã lớp: ")
    name = input("Tên lớp: ")
    schedule = input("Lịch học (cách nhau bằng dấu phẩy): ").split(",")
    teacher_id = input("Mã giảng viên phụ trách: ")

    teacher = next((t for t in data['teachers'] if t['id'] == teacher_id), None)
    if not teacher:
        print(" Giảng viên không tồn tại.")
        return

    data['classes'].append({
        "id": lop_id,
        "name": name,
        "schedule": [s.strip() for s in schedule],
        "teacher": teacher,
        "students": []
    })
    lua_du_lieu(data)
    print(" Thêm lớp thành công.")

def xoa_lop(data):
    class_id = input("Mã lớp cần xóa: ")
    data['classes'] = [c for c in data['classes'] if c['id'] != class_id]
    lua_du_lieu(data)
    print(" Đã xóa lớp.")

def sua_ten_lop(data):
    class_id = input("Mã lớp: ")
    new_name = input("Tên mới: ")
    for c in data['classes']:
        if c['id'] == class_id:
            c['name'] = new_name
            lua_du_lieu(data)
            print(" Đã cập nhật tên lớp.")
            return
    print(" Không tìm thấy lớp.")

def them_lich_trinh(data):
    class_id = input("Mã lớp: ")
    schedule = input("Lịch học mới: ")
    for c in data['classes']:
        if c['id'] == class_id:
            c['schedule'].append(schedule)
            lua_du_lieu(data)
            print(" Đã thêm lịch.")
            return
    print(" Không tìm thấy lớp.")

def xoa_lich_trinh(data):
    class_id = input("Mã lớp: ")
    schedule = input("Lịch học cần xóa: ")
    for c in data['classes']:
        if c['id'] == class_id and schedule in c['schedule']:
            c['schedule'].remove(schedule)
            lua_du_lieu(data)
            print(" Đã xóa lịch.")
            return
    print(" Không tìm thấy lịch trong lớp.")

def danh_sach_lop_hoc(data):
    for c in data['classes']:
        print(f"\n📘 {c['id']} - {c['name']}")
        print("  Lịch học:", ", ".join(c['schedule']))
        print("  GV phụ trách:", c['teacher']['name'])
        print("  Sĩ số:", len(c['students']))

def tim_kiem_lop_theo_giao_vien(data):
    teacher_id = input("Nhập mã giảng viên: ")
    found = [c for c in data['classes'] if c['teacher']['id'] == teacher_id]
    for c in found:
        print(f"{c['id']} - {c['name']} ({', '.join(c['schedule'])})")

def thay_doi_giao_vien_lop(data):
    class_id = input("Mã lớp: ")
    new_teacher_id = input("Mã giảng viên mới: ")
    teacher = next((t for t in data['teachers'] if t['id'] == new_teacher_id), None)
    for c in data['classes']:
        if c['id'] == class_id and teacher:
            c['teacher'] = teacher
            lua_du_lieu(data)
            print(" Đã đổi giảng viên.")
            return
    print(" Không tìm thấy lớp hoặc giảng viên.")

def tim_kiem_lop_theo_lich(data):
    keyword = input("Tìm theo lịch học (ví dụ: Thứ 2): ")
    found = [c for c in data['classes'] if any(keyword in s for s in c['schedule'])]
    for c in found:
        print(f"{c['id']} - {c['name']} ({', '.join(c['schedule'])})")

def xem_hoc_sinh_trong_lop(data):
    class_id = input("Mã lớp: ")
    for c in data['classes']:
        if c['id'] == class_id:
            print("Danh sách SV:", c['students'])
            return
    print(" Không tìm thấy lớp.")

def them_giao_vien(data):
    tid = input("Mã GV: ")
    name = input("Tên GV: ")
    email = input("Email: ")
    data['teachers'].append({"id": tid, "name": name, "email": email})
    lua_du_lieu(data)
    print(" Đã thêm giảng viên.")

def xoa_giao_vien(data):
    tid = input("Mã GV: ")
    data['teachers'] = [t for t in data['teachers'] if t['id'] != tid]
    lua_du_lieu(data)
    print(" Đã xóa giảng viên.")

def bien_tap_giao_vien(data):
    tid = input("Mã GV: ")
    for t in data['teachers']:
        if t['id'] == tid:
            t['name'] = input("Tên mới: ") or t['name']
            t['email'] = input("Email mới: ") or t['email']
            lua_du_lieu(data)
            print(" Đã cập nhật.")
            return
    print(" Không tìm thấy GV.")

def danh_sach_giao_vien(data):
    for t in data['teachers']:
        print(f"{t['id']} - {t['name']} ({t['email']})")

def them_hoc_sinh(data):
    sid = input("Mã SV: ")
    name = input("Tên SV: ")
    data['students'].append({"id": sid, "name": name})
    lua_du_lieu(data)
    print(" Đã thêm sinh viên.")

def xoa_hoc_sinh(data):
    sid = input("Mã SV: ")
    data['students'] = [s for s in data['students'] if s['id'] != sid]
    lua_du_lieu(data)
    print(" Đã xóa sinh viên.")

def sua_hoc_sinh(data):
    sid = input("Mã SV: ")
    for s in data['students']:
        if s['id'] == sid:
            s['name'] = input("Tên mới: ") or s['name']
            lua_du_lieu(data)
            print(" Đã cập nhật.")
            return
    print(" Không tìm thấy SV.")

def gan_hoc_sinh_cho_lop(data):
    class_id = input("Mã lớp: ")
    student_id = input("Mã SV: ")
    for c in data['classes']:
        if c['id'] == class_id:
            if student_id not in c['students']:
                c['students'].append(student_id)
                lua_du_lieu(data)
                print(" Đã gán SV vào lớp.")
                return
    print(" Không tìm thấy lớp.")

def xuat_du_lieu(data):
    filename = input("Tên file xuất (.json): ")
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    print(f" Đã xuất dữ liệu ra {filename}")

def nhap_du_lieu():
    filename = input("Tên file nhập (.json): ")
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    data = tai_du_lieu()
    while True:
        print("\n===== QUẢN LÝ LỚP HỌC =====")
        print("1. Thêm lớp")
        print("2. xóa lớp")
        print("3. Sửa tên lớp")
        print("4. Thêm lịch")
        print("5. Xóa lịch")
        print(" 6. Xem lớp")
        print("7. Tìm lớp theo GV")
        print("8. Đổi GV lớp")
        print("9. Tìm lớp theo lịch")
        print("10. Xem SV lớp")
        print("11. Thêm GV")
        print(" 12. Xóa GV")
        print(" 13. Sửa GV")
        print("14. Xem GV")
        print(" 15. Thêm SV")
        print("16. Xóa SV")
        print("17. Sửa SV")
        print("18. Gán SV vào lớp")
        print("19. Xuất dữ liệu")
        print("20. Nhập dữ liệu")
        print("0. Thoát")
        choice = input("Chọn: ")

        if choice == "1": them_lop(data)
        elif choice == "2": xoa_lop(data)
        elif choice == "3": sua_ten_lop(data)
        elif choice == "4": them_lich_trinh(data)
        elif choice == "5": xoa_lich_trinh(data)
        elif choice == "6": danh_sach_lop_hoc(data)
        elif choice == "7": tim_kiem_lop_theo_giao_vien  (data)
        elif choice == "8": thay_doi_giao_vien_lop(data)
        elif choice == "9": tim_kiem_lop_theo_lich(data)
        elif choice == "10": tim_kiem_lop_theo_lich(data)
        elif choice == "11": them_giao_vien(data)
        elif choice == "12": xoa_giao_vien(data)
        elif choice == "13": bien_tap_giao_vien(data)
        elif choice == "14": danh_sach_giao_vien(data)
        elif choice == "15": them_hoc_sinh(data)
        elif choice == "16": xoa_hoc_sinh(data)
        elif choice == "17": sua_hoc_sinh(data)
        elif choice == "18": gan_hoc_sinh_cho_lop(data)
        elif choice == "19": xuat_du_lieu(data)
        elif choice == "20": data = nhap_du_lieu(); lua_du_lieu(data)
        elif choice == "0": break
        else: print(" Lựa chọn không hợp lệ!")
  
if __name__ == "__main__":
    main()
