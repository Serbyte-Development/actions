# Summarize commits & send client email

Turn recent commits into polished client-facing update emails automatically.

This action uses OpenAI to summarize commit activity and generate an HTML email you can send to clients via SMTP.

## Features

- Summarizes recent commit messages with OpenAI
- Rewrites technical changes into client-friendly language
- Generates HTML and Markdown summary outputs
- Works with reusable workflows across many client repos

## Inputs

| Name | Required | Default | Description |
|---|---|---:|---|
| `openai-model` | No | `gpt-4o-mini` | OpenAI model used to generate the summary |
| `site-label` | No | `""` | Optional site or client label |

## Outputs

| Name | Description |
|---|---|
| `email_body` | Generated HTML email body |
| `summary_md` | Generated Markdown summary |

## Required secrets

- `OPENAI_API_KEY`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `CLIENT_EMAIL`

## Reusable workflow usage

```yaml
name: Commit Email Summary

on:
  push:
    branches: [main, master]

jobs:
  email_summary:
    uses: Serbyte-Development/actions/.github/workflows/send_commit_email.yaml@v1
    with:
      site_label: "Acme Dental"
    secrets: inherit
```

## Direct action usage

```yaml
name: Send Client Update

on:
  push:
    branches: [main, master]

jobs:
  send_update:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Generate summary
        id: summarize
        uses: Serbyte-Development/actions@v1
        with:
          openai-model: gpt-4o-mini
          site-label: Acme Dental
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

## Notes

- Reusable workflow inputs use underscores: `site_label`, `openai_model`
- Direct action inputs use hyphens: `site-label`, `openai-model`

## License

[MIT](LICENSE)

Built by [Serbyte Development](https://www.serbyte.net) 
