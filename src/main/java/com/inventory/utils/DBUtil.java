package com.inventory.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL = "jdbc:mysql://sql10.freesqldatabase.com:3306/sql10788361";
    private static final String USER = "sql10788361";
    private static final String PASSWORD = "WvQnRfWxX4"; // ⛔ Replace this

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // for MySQL 8.x
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
