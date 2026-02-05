# TODO: Optimize CardListView Performance

## Context
SwiftUI List can have performance issues with large card collections, especially with:
- Complex row views (images, multiple text fields, buttons)
- Real-time search/filter operations
- Frequent updates (favorites, last used date)

## Current Implementation
- CardListView uses standard List with NavigationLink
- CardRowView includes: card image (optional), name, store, barcode type badge, favorite button
- Filtered/sorted computed property recalculates on every search/sort change

## Optimization Strategies to Consider

### 1. LazyVStack instead of List (if needed)
```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(filteredAndSortedCards) { card in
            CardRowView(card: card)
        }
    }
}
```
- Pros: More control, better for custom layouts
- Cons: Lose built-in List features (separators, swipe actions)

### 2. Optimize CardRowView
- Use `@Query` directly in List instead of computed property
- Move expensive operations out of row view
- Cache barcode images if shown in list
- Use `equatable()` modifier to prevent unnecessary redraws

### 3. Consider `@Query` with predicates
Instead of filtering in computed property, use SwiftData's built-in filtering:
```swift
@Query(filter: #Predicate<LoyaltyCard> { card in
    searchText.isEmpty || card.name.contains(searchText)
}, sort: \LoyaltyCard.name) private var cards: [LoyaltyCard]
```

### 4. Profile First
- Use Instruments Time Profiler
- Test with 50+ cards
- Measure scroll FPS
- Identify actual bottlenecks before optimizing

## When to Address
- After basic functionality is complete
- When user testing reveals performance issues
- Before public release if handling >50 cards

## Priority
- Low (for MVP with <20 cards)
- Medium (for 20-50 cards)
- High (for 50+ cards or noticeable lag)

## Related
- Sprint 7: Polish & Features
- Sprint 10: MVP Release Prep (performance testing)
