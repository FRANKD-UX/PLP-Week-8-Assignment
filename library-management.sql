-- Library Management System Database
-- Created: May 13, 2025
AUthor Frank NDlovu 

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Create Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    membership_start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_end_date DATE,
    membership_status ENUM('Active', 'Expired', 'Suspended') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Add constraint to ensure membership_end_date is after membership_start_date
    CONSTRAINT chk_membership_dates CHECK (membership_end_date IS NULL OR membership_end_date > membership_start_date),
    
    -- Index on email for faster lookups
    INDEX idx_email (email),
    -- Index on last name for searching
    INDEX idx_last_name (last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Librarians table
CREATE TABLE librarians (
    librarian_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Index on email for faster lookups
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Add constraint to ensure death_date is after birth_date if provided
    CONSTRAINT chk_author_dates CHECK (death_date IS NULL OR death_date > birth_date),
    
    -- Index on author name for searching
    INDEX idx_author_name (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Index on publisher name for faster lookups
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Genres table
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INT,
    publication_date DATE,
    language VARCHAR(50) DEFAULT 'English',
    page_count INT,
    summary TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key referencing Publishers table
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    
    -- Indexes for faster lookups
    INDEX idx_title (title),
    INDEX idx_isbn (isbn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Book_Authors many-to-many relationship table
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    is_primary_author BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Composite primary key
    PRIMARY KEY (book_id, author_id),
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Book_Genres many-to-many relationship table
CREATE TABLE book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Composite primary key
    PRIMARY KEY (book_id, genre_id),
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Book_Copies table for physical copies inventory
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    acquisition_date DATE NOT NULL,
    copy_condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged', 'Lost') NOT NULL DEFAULT 'New',
    status ENUM('Available', 'Checked Out', 'On Hold', 'In Repair', 'Lost', 'Retired') NOT NULL DEFAULT 'Available',
    shelf_location VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key referencing Books table
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    
    -- Indexes for faster lookups
    INDEX idx_barcode (barcode),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    librarian_id INT,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') NOT NULL DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL,
    
    -- Add constraint to ensure return_date is after checkout_date if provided
    CONSTRAINT chk_loan_dates CHECK (return_date IS NULL OR return_date >= checkout_date),
    
    -- Indexes for faster lookups
    INDEX idx_member (member_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason ENUM('Late Return', 'Damaged Item', 'Lost Item') NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    paid_date DATETIME,
    status ENUM('Pending', 'Paid', 'Waived') NOT NULL DEFAULT 'Pending',
    librarian_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL,
    
    -- Indexes for faster lookups
    INDEX idx_member (member_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiration_date DATETIME NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') NOT NULL DEFAULT 'Pending',
    fulfillment_date DATETIME,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    
    -- Indexes for faster lookups
    INDEX idx_member (member_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Reviews table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    rating TINYINT NOT NULL,
    review_text TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    
    -- Ensure rating is between 1 and 5
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    
    -- Ensure a member can only review a book once
    UNIQUE KEY uk_member_book (member_id, book_id),
    
    -- Indexes for faster lookups
    INDEX idx_book_rating (book_id, rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Events table for library events
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    duration INT NOT NULL COMMENT 'Duration in minutes',
    location VARCHAR(255) NOT NULL,
    max_attendees INT,
    librarian_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key
    FOREIGN KEY (librarian_id) REFERENCES librarians(librarian_id) ON DELETE SET NULL,
    
    -- Indexes for faster lookups
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Event_Registrations table
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No-Show', 'Cancelled') NOT NULL DEFAULT 'Registered',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    
    -- Ensure a member can only register once for an event
    UNIQUE KEY uk_event_member (event_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Triggers

-- Trigger to update book_copies status when a loan is created
DELIMITER //
CREATE TRIGGER after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    UPDATE book_copies
    SET status = 'Checked Out'
    WHERE copy_id = NEW.copy_id;
END //
DELIMITER ;

-- Trigger to update book_copies status when a loan is updated (returned)
DELIMITER //
CREATE TRIGGER after_loan_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE book_copies
        SET status = 'Available'
        WHERE copy_id = NEW.copy_id;
    END IF;
END //
DELIMITER ;

-- Trigger to automatically calculate fine amounts for overdue books
DELIMITER //
CREATE TRIGGER after_overdue_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    DECLARE days_overdue INT;
    DECLARE fine_amount DECIMAL(10,2);
    
    -- Check if the book is returned late
    IF NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date THEN
        -- Calculate days overdue
        SET days_overdue = DATEDIFF(NEW.return_date, NEW.due_date);
        -- Calculate fine amount (e.g., $0.50 per day)
        SET fine_amount = days_overdue * 0.50;
        
        -- Insert fine record
        IF days_overdue > 0 THEN
            INSERT INTO fines (
                loan_id, 
                member_id, 
                amount, 
                reason, 
                issued_date, 
                due_date
            ) VALUES (
                NEW.loan_id, 
                NEW.member_id, 
                fine_amount, 
                'Late Return', 
                NOW(), 
                DATE_ADD(NOW(), INTERVAL 30 DAY)
            );
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger to automatically update loan status to 'Overdue' when due_date is passed
DELIMITER //
CREATE EVENT update_overdue_loans
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE loans
    SET status = 'Overdue'
    WHERE due_date < NOW() 
    AND return_date IS NULL 
    AND status = 'Active';
END //
DELIMITER ;

-- Create Views

-- View for available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    p.name AS publisher,
    b.publication_date,
    COUNT(bc.copy_id) AS available_copies
FROM 
    books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN book_copies bc ON b.book_id = bc.book_id AND bc.status = 'Available'
GROUP BY 
    b.book_id, b.title, b.isbn, p.name, b.publication_date
HAVING 
    COUNT(bc.copy_id) > 0;

-- View for overdue loans
CREATE VIEW overdue_loans AS
SELECT 
    l.loan_id,
    m.first_name AS member_first_name,
    m.last_name AS member_last_name,
    m.email AS member_email,
    b.title AS book_title,
    bc.barcode,
    l.checkout_date,
    l.due_date,
    DATEDIFF(NOW(), l.due_date) AS days_overdue
FROM 
    loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE 
    l.status = 'Overdue'
ORDER BY 
    days_overdue DESC;

-- View for member loan history
CREATE VIEW member_loan_history AS
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    b.title AS book_title,
    bc.barcode,
    l.checkout_date,
    l.due_date,
    l.return_date,
    l.status,
    CASE 
        WHEN l.return_date IS NULL AND l.due_date < NOW() THEN DATEDIFF(NOW(), l.due_date)
        WHEN l.return_date IS NOT NULL AND l.return_date > l.due_date THEN DATEDIFF(l.return_date, l.due_date)
        ELSE 0
    END AS days_overdue
FROM 
    members m
JOIN loans l ON m.member_id = l.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
ORDER BY 
    m.member_id, l.checkout_date DESC;

-- View for popular books
CREATE VIEW popular_books AS
SELECT 
    b.book_id,
    b.title,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    AVG(r.rating) AS average_rating,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM 
    books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
LEFT JOIN reviews r ON b.book_id = r.book_id
GROUP BY 
    b.book_id, b.title
ORDER BY 
    total_loans DESC, average_rating DESC;

-- Sample Data Insertion

-- Insert sample genres
INSERT INTO genres (name, description) VALUES
('Fiction', 'Literary works based on imagination'),
('Non-Fiction', 'Literary works based on facts'),
('Science Fiction', 'Fiction dealing with futuristic concepts'),
('Mystery', 'Fiction dealing with the solution of a crime'),
('Biography', 'Non-fiction account of someone\'s life'),
('History', 'Non-fiction accounts of past events'),
('Fantasy', 'Fiction involving magic or supernatural elements'),
('Self-Help', 'Books aimed at personal improvement'),
('Romance', 'Fiction focused on romantic relationships'),
('Thriller', 'Fiction characterized by suspense and excitement');

-- Insert sample publishers
INSERT INTO publishers (name, address, phone_number, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'info@hbgusa.com', 'www.hachettebookgroup.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com');

-- Insert sample authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British', 'British author best known for writing the Harry Potter fantasy series'),
('Stephen', 'King', '1947-09-21', 'American', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('Jane', 'Austen', '1775-12-16', 'British', 'English novelist known primarily for her six major novels'),
('George', 'Orwell', '1903-06-25', 'British', 'English novelist, essayist, journalist and critic'),
('Agatha', 'Christie', '1890-09-15', 'British', 'English writer known for her detective novels'),
('Harper', 'Lee', '1926-04-28', 'American', 'American novelist widely known for To Kill a Mockingbird'),
('F. Scott', 'Fitzgerald', '1896-09-24', 'American', 'American fiction writer famous for The Great Gatsby'),
('J.R.R.', 'Tolkien', '1892-01-03', 'British', 'English writer, poet, philologist, and academic, best known for The Lord of the Rings'),
('Leo', 'Tolstoy', '1828-09-09', 'Russian', 'Russian writer who is regarded as one of the greatest authors of all time'),
('Mark', 'Twain', '1835-11-30', 'American', 'American writer, humorist, entrepreneur, publisher, and lecturer');

-- Insert sample librarians
INSERT INTO librarians (first_name, last_name, email, phone_number, position, hire_date, is_admin) VALUES
('John', 'Smith', 'john.smith@library.org', '555-1234', 'Head Librarian', '2010-06-15', TRUE),
('Mary', 'Johnson', 'mary.johnson@library.org', '555-2345', 'Reference Librarian', '2015-03-10', FALSE),
('Robert', 'Davis', 'robert.davis@library.org', '555-3456', 'Cataloger', '2018-09-22', FALSE),
('Patricia', 'Wilson', 'patricia.wilson@library.org', '555-4567', 'Children\'s Librarian', '2012-11-05', FALSE),
('Michael', 'Brown', 'michael.brown@library.org', '555-5678', 'Systems Librarian', '2019-01-15', TRUE);

-- Insert sample members
INSERT INTO members (first_name, last_name, email, phone_number, address, date_of_birth, membership_start_date, membership_status) VALUES
('Alice', 'Anderson', 'alice.anderson@email.com', '555-1111', '123 Main St, Anytown', '1985-03-25', '2022-01-15', 'Active'),
('Bob', 'Baker', 'bob.baker@email.com', '555-2222', '456 Oak Ave, Someville', '1990-07-12', '2022-02-20', 'Active'),
('Charlie', 'Clark', 'charlie.clark@email.com', '555-3333', '789 Pine Rd, Othertown', '1978-11-08', '2022-03-10', 'Active'),
('Diana', 'Davis', 'diana.davis@email.com', '555-4444', '101 Elm St, Anytown', '1995-05-18', '2022-01-05', 'Active'),
('Edward', 'Evans', 'edward.evans@email.com', '555-5555', '202 Maple Dr, Someville', '1982-09-30', '2022-04-12', 'Active'),
('Fiona', 'Franklin', 'fiona.franklin@email.com', '555-6666', '303 Cedar Ln, Othertown', '1973-12-22', '2022-02-08', 'Active'),
('George', 'Grant', 'george.grant@email.com', '555-7777', '404 Birch Blvd, Anytown', '1988-04-15', '2022-03-25', 'Active'),
('Hannah', 'Harris', 'hannah.harris@email.com', '555-8888', '505 Walnut St, Someville', '1992-06-07', '2022-01-30', 'Active'),
('Ian', 'Ingram', 'ian.ingram@email.com', '555-9999', '606 Spruce Ave, Othertown', '1975-02-14', '2022-04-05', 'Active'),
('Julie', 'Jones', 'julie.jones@email.com', '555-0000', '707 Ash Rd, Anytown', '1998-08-29', '2022-02-15', 'Active');

-- Insert sample books
INSERT INTO books (title, isbn, publisher_id, publication_date, language, page_count, summary) VALUES
('To Kill a Mockingbird', '9780061120084', 2, '1960-07-11', 'English', 336, 'The story of young Scout Finch and her father, a lawyer defending a Black man accused of raping a white woman in the 1930s American South.'),
('1984', '9780451524935', 1, '1949-06-08', 'English', 328, 'A dystopian novel set in a totalitarian society where independent thinking is a crime.'),
('Pride and Prejudice', '9780141439518', 1, '1813-01-28', 'English', 432, 'A romantic novel following the character of Elizabeth Bennet as she deals with issues of manners, upbringing, morality, education, and marriage.'),
('The Great Gatsby', '9780743273565', 3, '1925-04-10', 'English', 180, 'A novel that follows a cast of characters living in the fictional towns of West Egg and East Egg on Long Island in the summer of 1922.'),
('The Hobbit', '9780547928227', 4, '1937-09-21', 'English', 310, 'A fantasy novel about the adventures of hobbit Bilbo Baggins, who is hired as a "burglar" by a group of dwarves.'),
('Murder on the Orient Express', '9780062693662', 2, '1934-01-01', 'English', 256, 'A detective novel featuring Belgian detective Hercule Poirot investigating a murder on the Orient Express train.'),
('The Shining', '9780307743657', 5, '1977-01-28', 'English', 447, 'A horror novel about a family who becomes snowbound in a hotel with a sinister presence.'),
('War and Peace', '9781400079988', 1, '1869-01-01', 'English', 1225, 'A novel that chronicles the history of the French invasion of Russia and the impact of the Napoleonic era on Tsarist society.'),
('The Adventures of Huckleberry Finn', '9780142437179', 1, '1884-12-10', 'English', 366, 'A novel about the journey of young Huck Finn and escaped slave Jim down the Mississippi River.'),
('Harry Potter and the Philosopher\'s Stone', '9780747532743', 3, '1997-06-26', 'English', 223, 'The first novel in the Harry Potter series about a young wizard who discovers his magical heritage.');

-- Link books with authors
INSERT INTO book_authors (book_id, author_id, is_primary_author) VALUES
(1, 6, TRUE),   -- To Kill a Mockingbird - Harper Lee
(2, 4, TRUE),   -- 1984 - George Orwell
(3, 3, TRUE),   -- Pride and Prejudice - Jane Austen
(4, 7, TRUE),   -- The Great Gatsby - F. Scott Fitzgerald
(5, 8, TRUE),   -- The Hobbit - J.R.R. Tolkien
(6, 5, TRUE),   -- Murder on the Orient Express - Agatha Christie
(7, 2, TRUE),   -- The Shining - Stephen King
(8, 9, TRUE),   -- War and Peace - Leo Tolstoy
(9, 10, TRUE),  -- The Adventures of Huckleberry Finn - Mark Twain
(10, 1, TRUE);  -- Harry Potter and the Philosopher's Stone - J.K. Rowling

-- Link books with genres
INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),  -- To Kill a Mockingbird - Fiction
(2, 3),  -- 1984 - Science Fiction
(3, 9),  -- Pride and Prejudice - Romance
(3, 1),  -- Pride and Prejudice - Fiction
(4, 1),  -- The Great Gatsby - Fiction
(5, 7),  -- The Hobbit - Fantasy
(6, 4),  -- Murder on the Orient Express - Mystery
(7, 1),  -- The Shining - Fiction
(7, 10), -- The Shining - Thriller
(8, 1),  -- War and Peace - Fiction
(8, 6),  -- War and Peace - History
(9, 1),  -- The Adventures of Huckleberry Finn - Fiction
(10, 7); -- Harry Potter and the Philosopher's Stone - Fantasy

-- Insert book copies
INSERT INTO book_copies (book_id, barcode, acquisition_date, copy_condition, status, shelf_location) VALUES
(1, 'LIB-00001-001', '2020-01-15', 'Good', 'Available', 'Fiction-A1'),
(1, 'LIB-00001-002', '2020-01-15', 'Good', 'Available', 'Fiction-A1'),
(2, 'LIB-00002-001', '2020-02-10', 'New', 'Available', 'Fiction-B2'),
(2, 'LIB-00002-002', '2020-02-10', 'Good', 'Available', 'Fiction-B2'),
(3, 'LIB-00003-001', '2020-01-20', 'Good', 'Available', 'Fiction-C3'),
(4, 'LIB-00004-001', '2020-03-05', 'Good', 'Available', 'Fiction-D4'),
(5, 'LIB-00005-001', '2020-02-25', 'Good', 'Available', 'Fantasy-E5'),
(5, 'LIB-00005-002', '2020-02-25', 'Fair', 'Available', 'Fantasy-E5'),
(6, 'LIB-00006-001', '2020-03-15', 'New', 'Available', 'Mystery-F6'),
(7, 'LIB-00007-001', '2020-04-10', 'Good', 'Available', 'Fiction-G7'),
(8, 'LIB-00008-001', '2020-01-30', 'Good', 'Available', 'Fiction-H8'),
(9, 'LIB-00009-001', '2020-02-15', 'Fair', 'Available', 'Fiction-I9'),
(10, 'LIB-00010-001', '2020-03-20', 'New', 'Available', 'Fantasy-J10'),
(10, 'LIB-00010-002', '2020-03-20', 'New', 'Available', 'Fantasy-J10'),
(10, 'LIB-00010-003', '2020-03-20', 'Good', 'Available', 'Fantasy-J10');

-- Insert loans
INSERT INTO loans (copy_id, member_id, librarian_id, checkout_date, due_date, return_date, status) VALUES
(1, 1, 1, '2023-01-10 10:30:00', '2023-01-24 10:30:00', '2023-01-22 14:15:00', 'Returned'),
(5, 2, 2, '2023-01-15 13:45:00', '2023-01-29 13:45:00', '2023-01-28 16:20:00', 'Returned'),
(7, 3, 1, '2023-02-01 09:15:00', '2023-02-15 09:15:00', '2023-02-10 11:30:00', 'Returned'),
(10, 4, 3, '2023-02-05 14:20:00', '2023-02-19 14:20:00', '2023-02-18 15:45:00', 'Returned'),
(12, 5, 2, '2023-02-10 11:00:00', '2023-02-24 11:00:00', '2023-02-23 10:10:00', 'Returned'),
(3, 6, 4, '2023-03-01 16:30:00', '2023-03-15 16:30:00', '2023-03-14 13:25:00', 'Returned'),
(9, 7, 3, '2023-03-05 10:45:00', '2023-03-19 10:45:00', '2023-03-18 14:50:00', 'Returned'),
(14, 8, 5, '2023-03-10 15:15:00', '2023-03-24 15:15:00', '2023-03-30 09:30:00', 'Returned'),
(2, 9, 1, '2023-04-01 12:00:00', '2023-04-15 12:00:00', NULL, 'Overdue'),
(13, 10, 2, '2023-04-05 11:30:00', '2023-04-19 11:30:00', NULL, 'Active');

-- Insert a fine for the overdue loan
INSERT INTO fines (loan_id, member_id, amount, reason, issued_date, due_date, paid_date, status, librarian_id) VALUES
(8, 8, 3.00, 'Late Return', '2023-03-30 09:30:00', '2023-04-30 09:30:00', '2023-04-10 14:15:00', 'Paid', 1),
(9, 9, 14.00, 'Late Return', '2023-04-20 09:00:00', '2023-05-20 09:00:00', NULL, 'Pending', NULL);

-- Insert reservations
INSERT INTO reservations (member_id, book_id, reservation_date, expiration_date, status) VALUES
(3, 10, '2023-04-01 09:00:00', '2023-04-08 09:00:00', 'Pending'),
(6, 7, '2023-04-02 14:30:00', '2023-04-09 14:30:00', 'Pending'),
(9, 5, '2023-03-15 10:15:00', '2023-03-22 10:15:00', 'Fulfilled'),
(2, 1, '2023-03-20 16:45:00', '2023-03-27 16:45:00', 'Cancelled');

-- Insert reviews
INSERT INTO reviews (book_id, member_id, rating, review_text, review_date) VALUES
(1, 1, 5, 'A timeless classic that everyone should read. The characters are so well developed.', '2023-01-25 09:30:00'),
(1, 3, 4, 'Great book with important social commentary. Highly recommended.', '2023-02-15 14:20:00'),
(2, 2, 5, 'One of the most influential dystopian novels ever written. Still relevant today.', '2023-01-30 11:15:00'),
(3, 4, 4, 'Austen\'s wit and social commentary make this an enduring classic.', '2023-02-20 16:40:00'),
(5, 5, 5, 'The perfect adventure story. Tolkien\'s world-building is unmatched.', '2023-02-25 13:10:00'),
(6, 6, 4, 'A brilliant mystery with an unexpected twist. Christie at her best.', '2023-03-16 15:30:00'),
(7, 7, 5, 'Terrifying and atmospheric. One of King\'s finest works.', '2023-03-20 10:45:00'),
(10, 8, 5, 'The book that introduced me to reading. Magical in every sense.', '2023-04-02 12:20:00'),
(10, 9, 4, 'A wonderful start to an amazing series. The characters are so engaging.', '2023-03-10 14:50:00'),
(10, 10, 5, 'Rowling\'s imagination and storytelling are exceptional. A modern classic.', '2023-03-15 09:25:00');

-- Insert events
INSERT INTO events (title, description, event_date, duration, location, max_attendees, librarian_id) VALUES
('Summer Reading Kickoff', 'Join us for the launch of our summer reading program with special guest authors!', '2023-06-01 14:00:00', 120, 'Main Hall', 100, 1),
('Book Club: To Kill a Mockingbird', 'Monthly book club discussing Harper Lee\'s classic novel.', '2023-05-15 18:30:00', 90, 'Meeting Room 2', 25, 2),
('Children\'s Story Time', 'Weekly story time for children ages 3-6.', '2023-05-10 10:00:00', 45, 'Children\'s Area', 20, 4),
('Introduction to Research Databases', 'Learn how to use the library\'s online research resources.', '2023-05-20 13:00:00', 60, 'Computer Lab', 15, 5),
('Poetry Reading Night', 'Local poets share their original works.', '2023-05-25 19:00:00', 120, 'Reading Garden', 50, 3);

-- Insert event registrations
INSERT INTO event_registrations (event_id, member_id, registration_date, attendance_status) VALUES
(1, 1, '2023-05-01 09:15:00', 'Registered'),
(1, 2, '2023-05-01 10:30:00', 'Registered'),
(1, 3, '2023-05-02 11:45:00', 'Registered'),
(2, 4, '2023-04-25 14:20:00', 'Registered'),
(2, 5, '2023-04-26 15:30:00', 'Registered'),
(2, 6, '2023-04-27 16:45:00', 'Registered'),
(3, 7, '2023-05-05 09:00:00', 'Registered'),
(3, 8, '2023-05-06 10:15:00', 'Registered'),
(4, 9, '2023-05-10 13:30:00', 'Registered'),
(5, 10, '2023-05-15 17:45:00', 'Registered');

-- Create stored procedures

-- Procedure to check out a book
DELIMITER //
CREATE PROCEDURE check_out_book(
    IN p_copy_id INT,
    IN p_member_id INT,
    IN p_librarian_id INT,
    IN p_due_days INT
)
BEGIN
    DECLARE v_copy_status VARCHAR(20);
    DECLARE v_member_status VARCHAR(20);
    DECLARE v_active_loans INT;
    DECLARE v_due_date DATETIME;
    
    -- Get copy status
    SELECT status INTO v_copy_status FROM book_copies WHERE copy_id = p_copy_id;
    
    -- Get member status
    SELECT membership_status INTO v_member_status FROM members WHERE member_id = p_member_id;
    
    -- Count active loans for the member
    SELECT COUNT(*) INTO v_active_loans FROM loans 
    WHERE member_id = p_member_id AND (status = 'Active' OR status = 'Overdue');
    
    -- Calculate due date
    SET v_due_date = DATE_ADD(NOW(), INTERVAL p_due_days DAY);
    
    -- Check conditions
    IF v_copy_status = 'Available' THEN
        IF v_member_status = 'Active' THEN
            IF v_active_loans < 5 THEN
                -- Insert loan record
                INSERT INTO loans (
                    copy_id, 
                    member_id, 
                    librarian_id, 
                    checkout_date, 
                    due_date, 
                    status
                ) VALUES (
                    p_copy_id, 
                    p_member_id, 
                    p_librarian_id, 
                    NOW(), 
                    v_due_date, 
                    'Active'
                );
                
                -- Update copy status
                UPDATE book_copies SET status = 'Checked Out' WHERE copy_id = p_copy_id;
                
                SELECT 'Book checked out successfully.' AS message;
            ELSE
                SELECT 'Error: Member has reached the maximum number of loans.' AS message;
            END IF;
        ELSE
            SELECT 'Error: Member account is not active.' AS message;
        END IF;
    ELSE
        SELECT 'Error: Book copy is not available.' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_copy_id INT,
    IN p_librarian_id INT
)
BEGIN
    DECLARE v_loan_id INT;
    DECLARE v_due_date DATETIME;
    DECLARE v_member_id INT;
    DECLARE v_days_overdue INT;
    
    -- Get loan information
    SELECT loan_id, due_date, member_id INTO v_loan_id, v_due_date, v_member_id
    FROM loans
    WHERE copy_id = p_copy_id AND return_date IS NULL
    ORDER BY checkout_date DESC
    LIMIT 1;
    
    IF v_loan_id IS NOT NULL THEN
        -- Update loan record
        UPDATE loans
        SET 
            return_date = NOW(),
            status = IF(NOW() > v_due_date, 'Overdue', 'Returned'),
            librarian_id = p_librarian_id
        WHERE loan_id = v_loan_id;
        
        -- Update copy status
        UPDATE book_copies SET status = 'Available' WHERE copy_id = p_copy_id;
        
        -- Calculate days overdue
        IF NOW() > v_due_date THEN
            SET v_days_overdue = DATEDIFF(NOW(), v_due_date);
            
            -- Create fine if overdue
            IF v_days_overdue > 0 THEN
                INSERT INTO fines (
                    loan_id,
                    member_id,
                    amount,
                    reason,
                    issued_date,
                    due_date,
                    status,
                    librarian_id
                ) VALUES (
                    v_loan_id,
                    v_member_id,
                    v_days_overdue * 0.50, -- $0.50 per day
                    'Late Return',
                    NOW(),
                    DATE_ADD(NOW(), INTERVAL 30 DAY),
                    'Pending',
                    p_librarian_id
                );
            END IF;
        END IF;
        
        SELECT 'Book returned successfully.' AS message;
    ELSE
        SELECT 'Error: No active loan found for this book copy.' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to renew a book
DELIMITER //
CREATE PROCEDURE renew_book(
    IN p_loan_id INT,
    IN p_additional_days INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_due_date DATETIME;
    DECLARE v_reservation_count INT;
    DECLARE v_renewals INT;
    
    -- Get loan information
    SELECT status, due_date INTO v_status, v_due_date
    FROM loans
    WHERE loan_id = p_loan_id;
    
    -- Count number of renewals
    SELECT COUNT(*) INTO v_renewals
    FROM loans_history
    WHERE loan_id = p_loan_id AND action = 'Renewal';
    
    -- Count reservations for this book
    SELECT COUNT(*) INTO v_reservation_count
    FROM reservations r
    JOIN book_copies bc ON bc.book_id = r.book_id
    JOIN loans l ON l.copy_id = bc.copy_id
    WHERE l.loan_id = p_loan_id
    AND r.status = 'Pending';
    
    -- Check conditions
    IF v_status = 'Active' THEN
        IF v_renewals < 2 THEN
            IF v_reservation_count = 0 THEN
                -- Update due date
                UPDATE loans
                SET 
                    due_date = DATE_ADD(due_date, INTERVAL p_additional_days DAY)
                WHERE loan_id = p_loan_id;
                
                -- Log renewal
                INSERT INTO loans_history (loan_id, action, action_date)
                VALUES (p_loan_id, 'Renewal', NOW());
                
                SELECT 'Book renewed successfully.' AS message;
            ELSE
                SELECT 'Error: Cannot renew, book is reserved by another member.' AS message;
            END IF;
        ELSE
            SELECT 'Error: Maximum number of renewals reached.' AS message;
        END IF;
    ELSE
        SELECT 'Error: Loan is not active.' AS message;
    END IF;
END //
DELIMITER ;

-- Create a loans_history table to track loan actions
CREATE TABLE loans_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    action ENUM('Checkout', 'Return', 'Renewal', 'Lost') NOT NULL,
    action_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    -- Foreign key
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    
    -- Index for faster lookups
    INDEX idx_loan_id (loan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Procedure to pay a fine
DELIMITER //
CREATE PROCEDURE pay_fine(
    IN p_fine_id INT,
    IN p_librarian_id INT
)
BEGIN
    UPDATE fines
    SET 
        paid_date = NOW(),
        status = 'Paid',
        librarian_id = p_librarian_id
    WHERE fine_id = p_fine_id AND status = 'Pending';
    
    IF ROW_COUNT() > 0 THEN
        SELECT 'Fine paid successfully.' AS message;
    ELSE
        SELECT 'Error: Fine not found or already paid.' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to search books by various criteria
DELIMITER //
CREATE PROCEDURE search_books(
    IN p_title VARCHAR(255),
    IN p_author VARCHAR(100),
    IN p_genre VARCHAR(50),
    IN p_availability VARCHAR(20)
)
BEGIN
    SELECT 
        b.book_id,
        b.title,
        b.isbn,
        GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
        GROUP_CONCAT(DISTINCT g.name SEPARATOR ', ') AS genres,
        p.name AS publisher,
        b.publication_date,
        COUNT(bc.copy_id) AS total_copies,
        SUM(CASE WHEN bc.status = 'Available' THEN 1 ELSE 0 END) AS available_copies
    FROM 
        books b
    LEFT JOIN book_authors ba ON b.book_id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.author_id
    LEFT JOIN book_genres bg ON b.book_id = bg.book_id
    LEFT JOIN genres g ON bg.genre_id = g.genre_id
    LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
    LEFT JOIN book_copies bc ON b.book_id = bc.book_id
    WHERE 
        (p_title IS NULL OR b.title LIKE CONCAT('%', p_title, '%')) AND
        (p_author IS NULL OR CONCAT(a.first_name, ' ', a.last_name) LIKE CONCAT('%', p_author, '%')) AND
        (p_genre IS NULL OR g.name = p_genre) AND
        (p_availability IS NULL OR 
         (p_availability = 'Available' AND EXISTS (
             SELECT 1 FROM book_copies bc2 
             WHERE bc2.book_id = b.book_id AND bc2.status = 'Available'
         )) OR
         (p_availability = 'Unavailable' AND NOT EXISTS (
             SELECT 1 FROM book_copies bc2 
             WHERE bc2.book_id = b.book_id AND bc2.status = 'Available'
         ))
        )
    GROUP BY 
        b.book_id, b.title, b.isbn, p.name, b.publication_date
    ORDER BY 
        b.title;
END //
DELIMITER ;

-- Procedure to generate monthly reports
DELIMITER //
CREATE PROCEDURE generate_monthly_report(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    
    SET v_start_date = CONCAT(p_year, '-', LPAD(p_month, 2, '0'), '-01');
    SET v_end_date = LAST_DAY(v_start_date);
    
    -- Books checked out in the month
    SELECT 'Books Checked Out' AS report_section;
    SELECT 
        COUNT(*) AS total_checkouts,
        COUNT(DISTINCT member_id) AS unique_members
    FROM 
        loans
    WHERE 
        checkout_date BETWEEN v_start_date AND v_end_date;
    
    -- Most popular books
    SELECT 'Most Popular Books' AS report_section;
    SELECT 
        b.title,
        COUNT(*) AS checkout_count
    FROM 
        loans l
    JOIN book_copies bc ON l.copy_id = bc.copy_id
    JOIN books b ON bc.book_id = b.book_id
    WHERE 
        l.checkout_date BETWEEN v_start_date AND v_end_date
    GROUP BY 
        b.book_id, b.title
    ORDER BY 
        checkout_count DESC
    LIMIT 5;
    
    -- Overdue books
    SELECT 'Overdue Books' AS report_section;
    SELECT 
        COUNT(*) AS total_overdue
    FROM 
        loans
    WHERE 
        due_date BETWEEN v_start_date AND v_end_date
        AND status = 'Overdue';
    
    -- Fines collected
    SELECT 'Fines Collected' AS report_section;
    SELECT 
        SUM(amount) AS total_fines_collected
    FROM 
        fines
    WHERE 
        paid_date BETWEEN v_start_date AND v_end_date
        AND status = 'Paid';
    
    -- New members
    SELECT 'New Members' AS report_section;
    SELECT 
        COUNT(*) AS new_members
    FROM 
        members
    WHERE 
        membership_start_date BETWEEN v_start_date AND v_end_date;
    
    -- Event attendance
    SELECT 'Event Attendance' AS report_section;
    SELECT 
        e.title AS event_name,
        COUNT(er.registration_id) AS registrations,
        COUNT(CASE WHEN er.attendance_status = 'Attended' THEN 1 END) AS attendees
    FROM 
        events e
    LEFT JOIN event_registrations er ON e.event_id = er.event_id
    WHERE 
        e.event_date BETWEEN v_start_date AND v_end_date
    GROUP BY 
        e.event_id, e.title;
END //
DELIMITER ;

-- Create indexes for performance optimization

-- Index on book titles for fast title searches
CREATE INDEX idx_book_title ON books(title);

-- Index on book publication date for filtering by date
CREATE INDEX idx_publication_date ON books(publication_date);

-- Index on loan checkout and due dates for reporting
CREATE INDEX idx_loan_dates ON loans(checkout_date, due_date);

-- Index on fine status for filtering unpaid fines
CREATE INDEX idx_fine_status ON fines(status);

-- Index on event dates for calendar views
CREATE INDEX idx_event_date ON events(event_date);

-- Create a function to calculate if a member has overdue items
DELIMITER //
CREATE FUNCTION has_overdue(p_member_id INT) RETURNS BOOLEAN
BEGIN
    DECLARE v_has_overdue BOOLEAN;
    
    SELECT EXISTS (
        SELECT 1 FROM loans
        WHERE member_id = p_member_id
        AND status = 'Overdue'
    ) INTO v_has_overdue;
    
    RETURN v_has_overdue;
END //
DELIMITER ;

-- Create a function to get a member's total outstanding fines
DELIMITER //
CREATE FUNCTION get_outstanding_fines(p_member_id INT) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE v_outstanding_amount DECIMAL(10,2);
    
    SELECT COALESCE(SUM(amount), 0.00) INTO v_outstanding_amount
    FROM fines
    WHERE member_id = p_member_id
    AND status = 'Pending';
    
    RETURN v_outstanding_amount;
END //
DELIMITER ;

-- Create a database backup trigger that runs daily
-- Note: This would normally be set up as a cron job or scheduled event in production
DELIMITER //
CREATE EVENT daily_backup
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- In a real system, this would call a stored procedure that uses MySQL's
    -- backup facilities or executes a system command to perform the backup
    INSERT INTO system_logs (log_type, message)
    VALUES ('BACKUP', CONCAT('Daily backup initiated at ', NOW()));
END //
DELIMITER ;

-- Create a system_logs table for tracking system events
CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_type ENUM('ERROR', 'WARNING', 'INFO', 'BACKUP', 'SECURITY') NOT NULL,
    message TEXT NOT NULL,
    log_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Index for filtering by log type
    INDEX idx_log_type (log_type),
    -- Index for filtering by date
    INDEX idx_log_time (log_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert some initial system logs
INSERT INTO system_logs (log_type, message) VALUES
('INFO', 'Library Management System database initialized'),
('INFO', 'Initial data loaded successfully');

-- Create a database user with limited privileges for the application
-- CREATE USER 'library_app'@'localhost' IDENTIFIED BY 'secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON library_management.* TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.check_out_book TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.return_book TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.renew_book TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.pay_fine TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.search_books TO 'library_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE library_management.generate_monthly_report TO 'library_app'@'localhost';
-- GRANT EXECUTE ON FUNCTION library_management.has_overdue TO 'library_app'@'localhost';
-- GRANT EXECUTE ON FUNCTION library_management.get_outstanding_fines TO 'library_app'@'localhost';

-- Final confirmation
SELECT 'Library Management System database setup complete!' AS message;
