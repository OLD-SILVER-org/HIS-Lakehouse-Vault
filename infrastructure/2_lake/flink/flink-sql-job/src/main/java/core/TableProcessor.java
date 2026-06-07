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
                return Arrays.stream(getTableSchemaDDL().split(","))
                                .map(line -> {
                                        String columnName = line.trim().split("\\s+")[0];
                                        String colExpr = String.format(
                                                        "CASE WHEN payload.op = 'd' THEN payload.before.%s ELSE payload.after.%s END",
                                                        columnName, columnName);

                                        if ("created_at".equals(columnName) || "updated_at".equals(columnName)) {
                                                String stringCol = String.format("TRIM(CAST(%s AS STRING))", colExpr);

                                                return String.format(
                                                                "CASE " +
                                                // Case 1: Epoch micros → convert to UTC ISO Z
                                                                                "WHEN %s SIMILAR TO '[0-9]+' THEN DATE_FORMAT(TO_TIMESTAMP_LTZ(TRY_CAST(%s AS BIGINT), 6), 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z''') "
                                                                                +
                                                // Case 2: Already in ISO Z format → keep as is
                                                                                "WHEN %s LIKE '%%Z' THEN %s " +
                                                // Fallback
                                                                                "ELSE %s " +
                                                                                "END",
                                                                stringCol, stringCol,
                                                                stringCol, stringCol,
                                                                stringCol);
                                        }
                                        return colExpr;
                                })
                                .collect(Collectors.joining(",\n"));
        }
}
