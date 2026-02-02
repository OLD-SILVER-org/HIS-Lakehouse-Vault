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
            // For 'd' operations, it selects data from 'payload.before' as 'payload.after' is null.
            return Arrays.stream(getTableSchemaDDL().split(","))
                    .map(line -> {
                        String columnName = line.trim().split("\\s+")[0]; // Correctly gets just the column name, e.g., "xa_phuong_id"
                        return String.format("CASE WHEN payload.op = 'd' THEN payload.before.%s ELSE payload.after.%s END",
                                columnName, columnName);
                    })
                    .collect(Collectors.joining(",\n"));
        }
}
