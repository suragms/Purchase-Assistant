# PROVIDER STATE BUGS

## Findings
- Realtime invalidation could trigger multiple duplicate invalidations in one poll cycle.
- Checklist optimistic state could remain sticky under certain completion/error timing.

## Implemented
- Batched notification and warehouse invalidations per realtime poll.
- Checklist completion now clears both busy and optimistic markers in finalization.

## Remaining
- Introduce explicit provider state machine for auth/session bootstrap.
- Add event cursor for realtime provider to reduce dedupe-key fragility.
