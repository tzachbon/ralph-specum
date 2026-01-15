# Tasks: Test Parallel Mixed Execution

## Phase 1: Mixed Execution Test

Test parallel batches separated by sequential tasks.

- [ ] 1.1 [P] Create first file in batch 1
  - **Do**: Create mixed-file-a.txt with content "File A from batch 1"
  - **Files**: `specs/test-parallel-mixed/mixed-file-a.txt`
  - **Done when**: File exists with correct content
  - **Verify**: `cat specs/test-parallel-mixed/mixed-file-a.txt | grep -q "File A from batch 1"`
  - **Commit**: `test: create file A in parallel batch 1`

- [ ] 1.2 [P] Create second file in batch 1
  - **Do**: Create mixed-file-b.txt with content "File B from batch 1"
  - **Files**: `specs/test-parallel-mixed/mixed-file-b.txt`
  - **Done when**: File exists with correct content
  - **Verify**: `cat specs/test-parallel-mixed/mixed-file-b.txt | grep -q "File B from batch 1"`
  - **Commit**: `test: create file B in parallel batch 1`

- [ ] 1.3 [VERIFY] Quality checkpoint: verify batch 1 complete
  - **Do**: Verify both files from batch 1 exist
  - **Verify**: `ls specs/test-parallel-mixed/mixed-file-a.txt specs/test-parallel-mixed/mixed-file-b.txt 2>/dev/null | wc -l | grep -q "2"`
  - **Done when**: Both batch 1 files exist
  - **Commit**: `chore: pass batch 1 checkpoint` (only if fixes needed)

- [ ] 1.4 [P] Create first file in batch 2
  - **Do**: Create mixed-file-c.txt with content "File C from batch 2"
  - **Files**: `specs/test-parallel-mixed/mixed-file-c.txt`
  - **Done when**: File exists with correct content
  - **Verify**: `cat specs/test-parallel-mixed/mixed-file-c.txt | grep -q "File C from batch 2"`
  - **Commit**: `test: create file C in parallel batch 2`

- [ ] 1.5 [P] Create second file in batch 2
  - **Do**: Create mixed-file-d.txt with content "File D from batch 2"
  - **Files**: `specs/test-parallel-mixed/mixed-file-d.txt`
  - **Done when**: File exists with correct content
  - **Verify**: `cat specs/test-parallel-mixed/mixed-file-d.txt | grep -q "File D from batch 2"`
  - **Commit**: `test: create file D in parallel batch 2`

- [ ] 1.6 Create sequential final file
  - **Do**: Create mixed-file-final.txt with content "Final file created sequentially"
  - **Files**: `specs/test-parallel-mixed/mixed-file-final.txt`
  - **Done when**: File exists with correct content
  - **Verify**: `cat specs/test-parallel-mixed/mixed-file-final.txt | grep -q "Final file"`
  - **Commit**: `test: create final sequential file`

## Notes

**Expected execution order**:
1. Tasks 1.1 and 1.2 execute in parallel (batch 1)
2. Task 1.3 executes sequentially (VERIFY checkpoint breaks parallel group)
3. Tasks 1.4 and 1.5 execute in parallel (batch 2)
4. Task 1.6 executes sequentially (no [P] marker)

**Validation criteria**:
- Batch 1 (1.1, 1.2): Should spawn 2 parallel executors
- Task 1.3: Should run alone after batch 1 completes
- Batch 2 (1.4, 1.5): Should spawn 2 parallel executors
- Task 1.6: Should run alone after batch 2 completes
