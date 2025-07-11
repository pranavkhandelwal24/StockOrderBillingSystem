package com.inventory.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL = "jdbc:postgresql://dpg-d1mfbhe3jp1c73eorc40-a.oregon-postgres.render.com:5432/nwrregister";
    private static final String USER = "nwrregister_user";
    private static final String PASSWORD = "SzVm76aXXa5Cpu3UjVxyXuGkXfVgIjQk";

    static {
        try {
            Class.forName("org.postgresql.Driver"); // Load PostgreSQL driver
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("PostgreSQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
