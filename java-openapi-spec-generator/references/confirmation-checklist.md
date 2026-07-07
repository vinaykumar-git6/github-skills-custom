# Confirmation Checklist

Ask the user to confirm **before** writing an operation into the spec whenever any of the
following are unclear from the source code. Batch your questions into a single message.

## Ask when...

- **Path or method is ambiguous** — e.g., `web.xml` maps `/api/customers/*` but the servlet
  parses `pathInfo` manually. Confirm the intended sub-routes (`/{id}`, `/{id}/accounts`).
- **Request body shape is unknown** — the handler reads raw input or a generic `Map`.
  Confirm field names, types, and which are required.
- **Response schema is derived dynamically** — JSON is built field-by-field. Confirm the
  full set of fields and their types.
- **Status codes are conditional** — confirm every status the endpoint can return and the
  condition that triggers it (e.g., `404` not found, `503` downstream outage).
- **Content types** — confirm if anything other than `application/json` is produced/consumed.
- **Auth** — confirm whether endpoints require authentication (API key, bearer, basic) so
  the spec's `securitySchemes` are correct.
- **Versioning / base path** — confirm the servlet context path and any API version prefix.

## How to ask

Present a compact table of what you inferred and a short list of open questions, e.g.:

> I documented 4 operations. Please confirm these 3 points before I generate the spec:
> 1. For `GET /api/customers/{id}/accounts`, when the customer has no accounts — is it
>    `200` with `[]` or `404`?
> 2. Is the `balance` field a decimal string or a JSON number?
> 3. Do any endpoints require an API key header?

Proceed only after the user answers, or explicitly says to use your best judgment.
