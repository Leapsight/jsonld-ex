.PHONY: help deps compile test test-framing bench bench-blank-node stress format

help:
	@echo "Available targets:"
	@echo "  deps              Install dependencies (mix deps.get)"
	@echo "  compile           Compile the project"
	@echo "  test              Run the full test suite"
	@echo "  test-framing      Run only the JSON-LD Framing test suites"
	@echo "  bench             Run the Benchee-based framing benchmark suite"
	@echo "  bench-blank-node  Run the blank-node-pruning regression benchmark"
	@echo "  stress            Run the large-graph stress test"
	@echo "  format            Run mix format"

deps:
	mix deps.get

compile:
	mix compile

test:
	MIX_ENV=test mix test

test-framing:
	MIX_ENV=test mix test test/unit/framing_test.exs test/unit/framing_comprehensive_test.exs test/unit/scoped_context_framing_test.exs

bench:
	MIX_ENV=prod mix run bench/framing_bench.exs

bench-blank-node:
	MIX_ENV=prod mix run bench/blank_node_pruning_bench.exs

stress:
	MIX_ENV=prod mix run bench/stress_test.exs

format:
	mix format
