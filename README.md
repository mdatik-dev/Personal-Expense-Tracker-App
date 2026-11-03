# Expense Tracker

A clean, modern Flutter application for keeping personal income and expenses organized. Transactions are stored locally in SQLite, so your records remain available after the app is closed and reopened.

## What the app includes

- **Dashboard:** A clear overview of total income, total expenses, and current balance.
- **Transaction history:** Browse saved transactions in a date-ordered list. Income and expenses use distinct colors and icons.
- **Add transaction:** Record a title, amount, category, transaction type, and date.
- **Transaction details:** Open any record to see its complete information.
- **Edit transaction:** Update an existing record with its saved values pre-filled.
- **Delete transaction:** Confirm before deleting a record.
- **Live summaries:** Dashboard totals and balance are recalculated from the saved transaction data whenever a record is added, edited, or deleted.
- **Offline storage:** Uses the `sqflite` SQLite database on the device.

## How it works

1. Open the app to see your financial summary and transaction history.
2. Tap the **+** button to add an income or expense.
3. Choose a category and date, enter a positive amount, and save.
4. Tap a transaction to view its details.
5. Use **Edit** to update it, or **Delete** to remove it after confirmation.
6. The dashboard refreshes automatically after every change.

## Technology

- Flutter and Dart
- Material 3 interface
- SQLite using `sqflite`
- `path` for database file paths
- `intl` for date and currency formatting

## Database

The database file is named `expense_tracker.db` and contains a `transactions` table:

| Column | SQLite type | Purpose |
|---|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | Unique transaction identifier |
| `title` | TEXT | Transaction title |
| `amount` | REAL | Positive transaction amount |
| `category` | TEXT | Selected category |
| `type` | TEXT | `Income` or `Expense` |
| `date` | TEXT | Transaction date in ISO-8601 format |


## Project structure

```text
expense_tracker/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── transaction_model.dart
│   ├── database/
│   │   └── database_helper.dart
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── transaction_form_screen.dart
│   │   └── transaction_details_screen.dart
│   └── widgets/
│       ├── summary_card.dart
│       └── transaction_tile.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```
