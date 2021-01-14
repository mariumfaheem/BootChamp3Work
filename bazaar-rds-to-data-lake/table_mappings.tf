locals {
  table_mappings = {
    "rules": [
      {
        rule-type: "selection",
        rule-id: "1",
        rule-name: "all-bazaar-databases",
        object-locator: {
          "schema-name": "bazaar%",
          "table-name": "%"
        },
        rule-action: "include",
        filters: []
      }
    ]
  }
}