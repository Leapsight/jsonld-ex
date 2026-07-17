# Regression benchmark for the O(n^2) blank-node-pruning bug fixed in
# JSON.LD.Framing.prune_blank_node_identifiers/2.
#
# Reproduces the shape that triggered it: each row carries one embedded
# object with no @id of its own (e.g. a location/address column), so it
# becomes a distinct single-occurrence blank node in the flattened node map.
# Before the fix, framing cost scaled as O(blank_nodes * tree_size) because
# the pruner re-scanned the whole result tree once per single-occurrence
# blank node. After the fix it should scale linearly with row count.
#
# Run with: mix run bench/blank_node_pruning_bench.exs

alias JSON.LD

defmodule BlankNodePruningBench do
  def build_input(row_count) do
    %{
      "@context" => %{"ex" => "http://example.org/"},
      "@graph" =>
        for i <- 1..row_count do
          %{
            "@id" => "ex:row#{i}",
            "@type" => "ex:Row",
            "ex:name" => "Row #{i}",
            "ex:location" => %{
              "ex:lat" => i * 1.0,
              "ex:lng" => i * -1.0,
              "ex:label" => "Location for row #{i}"
            }
          }
        end
    }
  end

  def frame do
    %{
      "@context" => %{"ex" => "http://example.org/"},
      "@type" => "ex:Row"
    }
  end

  def run do
    sizes = [100, 200, 400, 800, 1600]

    IO.puts("\n=== Blank Node Pruning Scaling (embedded-object-per-row) ===\n")

    results =
      Enum.map(sizes, fn size ->
        input = build_input(size)

        {time_us, _result} =
          :timer.tc(fn -> JSON.LD.frame(input, frame()) end)

        time_ms = time_us / 1_000
        IO.puts("  #{size} rows: #{Float.round(time_ms, 2)} ms")
        {size, time_ms}
      end)

    IO.puts("\n  Pairwise scaling factor (~1.0x = linear, growth toward 2.0x = quadratic):")

    results
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.each(fn [{size1, time1}, {size2, time2}] ->
      ratio = if time1 > 0, do: (time2 / time1) / (size2 / size1), else: 0.0
      IO.puts("    #{size1} -> #{size2}: #{Float.round(ratio, 2)}x")

      if ratio > 1.5 do
        IO.puts("    ⚠️  Warning: scaling looks super-linear")
      end
    end)

    IO.puts("\n=== Done ===")
  end
end

BlankNodePruningBench.run()
