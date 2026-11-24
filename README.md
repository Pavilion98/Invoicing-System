This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.js`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Repository Workflow Conventions

Suggested defaults for this project. If the SE Excellence program or reviewer provides a stricter convention, follow that instead.

## Branch naming

Do not work directly on the default branch (main is assumed; use the repository's actual default branch if it differs). Create a branch for each issue:

- feat/<issue-number>-short-description — new functionality
- fix/<issue-number>-short-description — bug fixes
- chore/<issue-number>-short-description — maintenance, tooling, dependencies
- docs/<issue-number>-short-description — documentation-only changes
- test/<issue-number>-short-description — test-only changes
  Use lowercase kebab-case descriptions. Keep a branch focused on one issue or a small set of closely related sub-issues.

## Pull-request rules

1. Open a pull request from the work branch into the default branch.
2. Use a clear title, preferably feat: ..., fix: ..., chore: ..., docs: ..., or test: ....
3. Link the GitHub issue in the PR description using Closes #<issue-number> when the PR fully completes that issue.
4. Explain what changed, why it changed, how it was tested, and note any migration or environment-variable changes.
5. Attach screenshots for meaningful UI changes and include the mobile viewport check when relevant.
6. Do not commit .env, credentials, real client information, or private invoice PDFs. Update .env.example when configuration changes.
7. Run the relevant checks before requesting review: Prisma validation/generation for schema changes, tests, lint, and production build.
8. Merge only after acceptance criteria pass and review/checks are complete. Delete the branch after merge if it is no longer needed.
   Definition of Done
   A backlog item is Done only when all applicable criteria below are satisfied:

- [ ] Implementation meets the issue acceptance criteria and stays within approved Round 02 scope.
- [ ] Code follows repository conventions and is committed on the appropriate branch.
- [ ] Input validation, business rules, authorization, and error handling are implemented where relevant.
- [ ] Automated tests cover success paths, validation failures, and important edge cases. Concurrency-sensitive invoice numbering, payment, and void operations have concurrency tests.
- [ ] npx prisma validate and npx prisma generate pass when Prisma schema/client code changes.
- [ ] Relevant migrations are committed and tested against a clean development database. PostgreSQL-specific indexes, constraints, functions, and triggers are included in migrations where required.
- [ ] Application build and lint pass; known failing tests are resolved or explicitly documented.
- [ ] UI changes are checked at 375px mobile width and desktop width where applicable.
- [ ] No secrets, credentials, real client financial data, or private PDF files are committed.
- [ ] API, environment-variable examples, and developer documentation are updated where applicable.
- [ ] A pull request is linked to the issue, reviewed, and approved according to the repository PR rules.
- [ ] The pull request is merged into the default branch; the issue is closed only after acceptance criteria are met.
      Do not mark work Done merely because the code was written or works locally. Acceptance criteria, relevant tests, migration safety, and review must be satisfied.
