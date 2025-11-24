package Quanlykhachsan;

import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        HotelManager hm = new HotelManager();
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("\n===== PHẦN MỀM QUẢN LÝ KHÁCH SẠN =====");
            System.out.println("1. Thêm phong");
            System.out.println("2. Xem danh sách phong");
            System.out.println("3. Thêm khách hàng");
            System.out.println("4. Tao đat phong");
            System.out.println("5. Xem danh sách đat phong");
            System.out.println("0. Thoát");
            System.out.print("Chon: ");

            int choice = sc.nextInt();
            sc.nextLine();

            switch (choice) {
                case 1 -> {
                    System.out.print("Nhập số phòng: ");
                    String num = sc.nextLine();
                    System.out.print("Nhập loại phòng: ");
                    String type = sc.nextLine();
                    System.out.print("Nhập giá: ");
                    double price = sc.nextDouble();
                    hm.addRoom(num, type, price);
                }
                case 2 -> hm.listRooms();
                case 3 -> {
                    System.out.print("Tên khách hàng: ");
                    String name = sc.nextLine();
                    System.out.print("Số điện thoại: ");
                    String phone = sc.nextLine();
                    hm.addCustomer(name, phone);
                }
                case 4 -> {
                    System.out.print("Số điện thoại khách: ");
                    String phone = sc.nextLine();
                    System.out.print("Số phòng: ");
                    String room = sc.nextLine();
                    System.out.print("Số đêm: ");
                    int nights = sc.nextInt();
                    hm.createReservation(phone, room, nights);
                }
                case 5 -> hm.listReservations();
                case 0 -> {
                    System.out.println("Thoát chương trình...");
                    return;
                }
                default -> System.out.println(" Lựa chọn không hợp lệ!");
            }
        }
    }
}
