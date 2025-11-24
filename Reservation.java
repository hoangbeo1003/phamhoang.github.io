package Quanlykhachsan;

public class Reservation {
    private String reservationId;
    private Customer customer;
    private Room room;
    private int nights;
    private double totalPrice;
    private String status; // Booked – CheckedIn – CheckedOut

    public Reservation(String reservationId, Customer customer, Room room, int nights) {
        this.reservationId = reservationId;
        this.customer = customer;
        this.room = room;
        this.nights = nights;
        this.totalPrice = room.getPrice() * nights;
        this.status = "Booked";
    }

    public String getReservationId() { return reservationId; }
    public Customer getCustomer() { return customer; }
    public Room getRoom() { return room; }
    public double getTotalPrice() { return totalPrice; }
    public String getStatus() { return status; }

    public void checkIn() { this.status = "CheckedIn"; }
    public void checkOut() {
        this.status = "CheckedOut";
        room.setAvailable(true);
    }

    @Override
    public String toString() {
        return "Đặt phòng {" +
                "ID phòng'" + reservationId + '\'' +
                ", Khách hàng :" + customer.getName() +
                ", Số phòng :" + room.getRoomNumber() +
                ", Đêm :" + nights +
                ", Tổng giá :" + totalPrice +
                ", Trạng thái : '" + status + '\'' +
                '}'; 
    }
}
