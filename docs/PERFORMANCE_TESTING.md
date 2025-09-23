# Performance Testing Scripts

Performance testing scripts for database optimization and benchmarking.

## Files

- `004_baseline_test.sql` - Baseline performance test (run before optimization)
- `005_optimization.sql` - Add strategic indexes for optimization
- `006_comparison_test.sql` - Performance comparison (run after optimization)

## Usage

### Option 1: pgAdmin Query Tool (Manual)
1. Open pgAdmin at http://localhost:8080
2. Connect to "MFB Database" → `mfbdb` database
3. Open Query Tool
4. Copy-paste file contents from `db/performance/` directory
5. Run each script in order (004 → 005 → 006)

### Option 2: Docker CLI (Automated)
```bash
# Run all performance tests via command line
docker exec -i mfb_postgres psql -U mfb -d mfbdb -f /performance_scripts/004_baseline_test.sql
docker exec -i mfb_postgres psql -U mfb -d mfbdb -f /performance_scripts/005_optimization.sql
docker exec -i mfb_postgres psql -U mfb -d mfbdb -f /performance_scripts/006_comparison_test.sql
```

## Expected Results

**Baseline (004):** Shows sequential scans and higher execution times
**Optimization (005):** Creates indexes to improve performance
**Comparison (006):** Shows index scans and lower execution times

Look for improvements in:
- Execution times (should decrease significantly)
- Query plans (index scans vs sequential scans)
- Cost estimates (should be lower)