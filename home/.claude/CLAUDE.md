- In all interaction and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Code Quality Standards

- Make minimal, surgical changes
- **Never compromise type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (`as Type`)
- Only create comments when relevant. Comments must be all lowercase

### React / Next.js
- Always use the latest Next.js version with most modern features
- Design Next.js pages, routes, and components with **Composability** in mind, **default to React Server Components** while sparingly using `"use client"` for user interactions.
