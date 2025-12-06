# The "Open Door" Library Initiative

**Narrative**: As a local community library, our mission is to democratize access to knowledge while ensuring the responsible stewardship of our collection.

**The Public & Community Members**: We believe knowledge should be barrier-free. Therefore, any visitor—regardless of registration status—must be able to search and explore our catalog by title, author, or genre instantly. However, to maintain inventory integrity, only Registered Members in good standing (no overdue books) are permitted to borrow physical copies.

**The Member Experience**: Members need clarity. When they borrow a book, they must know exactly when it is due (strictly 2 weeks from checkout). They expect the system to prevent them from accidentally borrowing duplicates or unavailable items.

**The Librarian Experience**: For our staff, efficiency is key. Librarians need a centralized command center to:
 - Manage the catalog (CRUD) without technical hurdles.
 - Instantly identify which books are overdue and who has them, facilitating timely follow-ups.
 - Process returns quickly to make popular books available again immediately.

**Technical Constraint (The "Best Seller" Scenario)**: Since popular books are in high demand, the system must handle concurrent borrowing attempts gracefully (e.g., two members trying to borrow the last copy of Harry Potter simultaneously), ensuring inventory numbers never drift.