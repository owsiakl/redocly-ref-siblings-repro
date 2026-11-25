# Keywords next to a schema `$ref` are lost

`ItemCreate` in `openapi.yaml` references `ItemWrite` and adds a required
`status`:

```yaml
ItemWrite:
  type: object
  properties:
    name:
      type: string
  required:
    - name
ItemCreate:
  $ref: '#/components/schemas/ItemWrite'
  unevaluatedProperties: false
  properties:
    status:
      type: string
      enum: [draft, scheduled]
  required:
    - status
```

From OpenAPI 3.1 on, the keywords next to a schema `$ref` apply together
with the referenced schema. The body of `POST /items` takes a required
`name` and a required `status`.

Two Redocly tools each drop one of the two fields:

- `redocly generate-client` emits `ItemCreate` with only `name`, in the
  TypeScript type and in the zod schema. It prints no warning.
- The API docs list only `status` in the request body of `POST /items`. The
  request sample on the same page has both `name` and `status`.

## Reproduce

Requires Node.js 22.22 or later and curl.

```sh
./run.sh                        # latest @redocly/cli and @redocly/framework
./run.sh 2.77.0 1.0.0-next.1    # specific versions
```

The script generates the client, starts the docs development server on port
4001, and prints what each tool has for `ItemCreate`:

```
--- Generated ItemCreate type ---
@redocly/cli 2.77.0
export type ItemCreate = {
    /**
     * Name of the item.
     */
    name: string;
};

--- Generated ItemCreate zod schema ---
export const ItemCreateSchema = z.object({
    name: z.string()
});

--- API docs page of POST /items ---
@redocly/framework 1.0.0-next.1
name    field list: no   request sample: yes
status  field list: yes  request sample: yes
```

Expected: `name` and `status` in the type, in the zod schema, and in the
field list.

To look at the page, run
`npx --yes --package @redocly/framework realm develop --port 4001` in this
folder and open <http://localhost:4001/openapi/other/createitem>.

Confirmed with `@redocly/cli` 2.77.0, 2.82.0, and 2.83.0, and with
`@redocly/framework` 0.140.1, 1.0.0-next.1, and 1.0.0-next.20.
