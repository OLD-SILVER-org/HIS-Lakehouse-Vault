package core;

import java.util.Arrays;
import java.util.stream.Collectors;

public interface TableProcessor {
        String getSourceTableName();

        String getTableSchemaDDL();

        String getPartitionKey();

        default String getInsertColumns() {
                // Extracts column names from the schema DDL
                return Arrays.stream(getTableSchemaDDL().split(","))
                                .map(line -> line.trim().split("\\s+")[0])
                                .collect(Collectors.joining(",\n"));
        }

        default String getSelectColumns() {
                // Creates the SELECT part of the INSERT statement
                // Handles 'c' (create), 'u' (update), and 'd' (delete) operations.
                // For 'd' operations, it selects data from 'payload.before' as 'payload.after'
                // is null.
                return Arrays.stream(getTableSchemaDDL().split(","))
                                .map(line -> {
                                        String columnName = line.trim().split("\\s+")[0]; // Correctly gets just the
                                                                                          // column name, e.g.,
                                                                                          // "xa_phuong_id"
                                        String colExpr = String.format(
                                                        "CASE WHEN payload.op = 'd' THEN payload.before.%s ELSE payload.after.%s END",
                                                        columnName, columnName);

                                        if ("created_at".equals(columnName) || "updated_at".equals(columnName)) {
                                                // Check if timezone (+0700) is missing and append it before conversion.
                                                // Logic: If the string does not end with ' +0700', then append it.
                                                String normalizedExpr = String.format(
                                                                "CASE WHEN %s NOT LIKE '%% +0700' THEN %s || ' +0700' ELSE %s END",
                                                                colExpr, colExpr, colExpr);

                                                // Convert to TIMESTAMP to synchronize data types in Iceberg
                                                return String.format("TO_TIMESTAMP(%s)", normalizedExpr);
                                        }
                                        return colExpr;
                                })
                                .collect(Collectors.joining(",\n"));
        }
}
