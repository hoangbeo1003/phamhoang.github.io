package Quanlykhachsan;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class HotelManager {
    private List<Room> rooms = new ArrayList<>();
    private List<Customer> customers = new ArrayList<>();
    private List<Reservation> reservations = new ArrayList<>();

  
    public void addRoom(String number, String type, double price) {
        String id = UUID.randomUUID().toString();
        rooms.add(new Room(id, number, type, price, true));
        System.out.println(" Thêm phong thành công!");
    }

    public void listRooms() {
        if (rooms.isEmpty()) {
            System.out.println(" Chưa có phòng nào!");
            return;
        }
        rooms.forEach(System.out::println);
    }

    public Room findRoom(String roomNumber) {
        for (Room r : rooms) {
            if (r.getRoomNumber().equals(roomNumber)) return r;
        }
        return null;
    }

    
    public void addCustomer(String name, String phone) {
        String id = UUID.randomUUID().toString();
        customers.add(new Customer(id, name, phone));
        System.out.println("Thêm khách hàng thành công!");
    }

    public Customer findCustomer(String phone) {
        for (Customer c : customers) {
            if (c.getPhone().equals(phone)) return c;
        }
        return null;
    }

    // ------------------ RESERVATION ------------------
    public void createReservation(String phone, String roomNumber, int nights) {
        Customer c = findCustomer(phone);
        Room r = findRoom(roomNumber);

        if (c == null) {
            System.out.println("Không tìm thấy khách hàng!");
            return;
        }
        if (r == null || !r.isAvailable()) {
            System.out.println("Phong không tồn tại hoặc không con trống!");
            return;
        }

        String id = UUID.randomUUID().toString();
        Reservation reservation = new Reservation(id, c, r, nights);
        reservations.add(reservation);
        r.setAvailable(false);

        System.out.println(" Đặt phong thành công!");
        System.out.println(reservation);
    }

    public void listReservations() {
        if (reservations.isEmpty()) {
            System.out.println(" Chưa có đặt phong nào!");
            return;
        }
        reservations.forEach(System.out::println);
    }
}
