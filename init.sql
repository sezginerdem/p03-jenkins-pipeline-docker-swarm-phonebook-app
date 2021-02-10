CREATE TABLE phonebook_db.phonebook(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    number VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO phonebook_db.phonebook (name, number)
    VALUES
        ("Sezgin", "1234567890"),
        ("Jason O", "12345678"),
        ("Talha", "3467567"),
        ("Jack Steve Anderson ", "345267"),
        ("James Scofield ", "345267"),
        ("Vincenzo Altobelli", "876543554");
