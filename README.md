# Library Management System

A comprehensive MySQL database system designed to manage all aspects of a modern library's operations.

## Project Description

This Library Management System is a relational database solution that enables libraries to effectively manage their collections, member interactions, and daily operations. It provides a robust framework for tracking books, managing loans and returns, handling reservations, collecting fines, organizing events, and generating operational reports.

### Key Features

- **Complete Book Management**: Track books, authors, publishers, genres, and individual book copies
- **Member Management**: Store member information and track membership status
- **Loan Processing**: Handle checkouts, returns, and renewals with automated due date calculation
- **Fine Management**: Automatically calculate and track overdue fines
- **Reservation System**: Allow members to reserve books that are currently unavailable
- **Event Management**: Schedule and manage library events with member registration
- **Review System**: Enable members to rate and review books
- **Reporting Tools**: Generate reports on library usage and trends
- **Data Integrity**: Enforce referential integrity through proper constraints and relationships

## Database Schema

The system consists of these primary tables:

- `members`: Stores library member information
- `librarians`: Records staff information and access levels
- `books`: Contains basic book information
- `authors`: Stores author details
- `publishers`: Records publisher information
- `genres`: Lists book categories/genres
- `book_copies`: Tracks individual physical copies of books
- `loans`: Records book checkouts, returns, and due dates
- `fines`: Manages monetary penalties for late returns or damages
- `reservations`: Handles book reservation requests
- `reviews`: Stores member reviews and ratings of books
- `events`: Manages library events and programs
- `event_registrations`: Tracks member registration for events

Additional auxiliary tables and relationships:
- `book_authors`: Many-to-many relationship between books and authors
- `book_genres`: Many-to-many relationship between books and genres
- `loans_history`: Audit trail for loan-related actions
- `system_logs`: System-wide logging for monitoring and troubleshooting

## Entity Relationship Diagram (ERD)

![Library Management System ERD](https://example.com/library_management_erd.png)

## Setup Instructions

1. Clone this repository to your local machine
2. Ensure you have MySQL Server 8.0 or higher installed
3. Log in to MySQL as a user with administrative privileges
4. Run the SQL script to create and populate the database:

```bash
mysql -u root -p < library_management.sql
```

5. Verify the database was created successfully:

```bash
mysql -u root -p
use library_management;
show tables;
```

## Features and Usage

### Core Functionality

- **Book Search**: Use the `search_books` stored procedure to find books by title, author, genre, or availability
- **Checkout Process**: The `check_out_book` procedure manages the loan process
- **Return Process**: Use `return_book` to process returns and automatically calculate fines
- **Renewals**: Extend due dates with the `renew_book` procedure (subject to availability)
- **Fine Payment**: Process payments using the `pay_fine` procedure

### Views for Common Tasks

- `available_books`: Shows all books with at least one available copy
- `overdue_loans`: Lists all currently overdue loans with member contact information
- `member_loan_history`: Provides a complete loan history for each member
- `popular_books`: Ranks books by checkout frequency and ratings

### Reporting

Generate monthly activity reports using the `generate_monthly_report` procedure, which provides:
- Total checkouts and unique member count
- Most popular books
- Overdue statistics
- Fine collection totals
- New member registrations
- Event attendance figures

## Security Considerations

The system includes:
- Input validation through constraints and stored procedures
- Data integrity through proper relationships and foreign keys
- User-level security with granular permissions (commented in the script)
- Activity logging for audit purposes

## Future Enhancements

Potential additions to the system:
- Digital content management
- Integrated payment processing
- Self-checkout functionality
- Enhanced reporting and analytics
- Mobile notification system
- Integration with external catalogs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Contact

frankdafrica@gmail.com
