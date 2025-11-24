package Quanlykhachsan;

public class Room {
    private String roomId;
    private String roomNumber;
    private String roomType;
    private double price;
    private boolean available;

    public Room(String roomId, String roomNumber, String roomType, double price, boolean available) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.price = price;
        this.available = available;
    }

    public String getRoomId() { return roomId; }
    public String getRoomNumber() { return roomNumber; }
    public String getRoomType() { return roomType; }
    public double getPrice() { return price; }
    public boolean isAvailable() { return available; }

    public void setAvailable(boolean available) { this.available = available; }

    @Override
    public String toString() {
        return "Room{" +
                " Số phòng :'" + roomNumber + '\'' +
                ", Loại phòng :'" + roomType + '\'' +
                ", Giá :" + price +
                ", Có sẵn : " + available +
                '}';
    }
}
