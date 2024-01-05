# Busbud dbt

Busbud's dbt monorepo.

We decided to use a monorepo because it's the easiest way to share core business logic and to have all the model documentation in one place (see [blog post](https://discourse.getdbt.com/t/how-to-configure-your-dbt-repository-one-or-many/2121) for more information on how to organize a dbt project).

## Local Setup

You will first need to install the Google Cloud SDK as instructed in the [engineering setup](https://docs.busbud-int.com/engineering/setup/) documentation.

If this is the first time you install dbt on your local machine, you will need to create a `profiles.yml` file in the `.dbt` folder.

```bash
mkdir ~/.dbt
touch ~/.dbt/profiles.yml
```

The busbud-dbt project has been configured to use a profile called `busbud_dbt`. You can set it up locally by copying and pasting the below yaml code to the `profiles.yml` file that you just created.

```yaml
busbud_dbt:
  outputs:
    dev:
      dataset: temp_power
      job_execution_timeout_seconds: 300
      job_retries: 1
      location: northamerica-northeast1
      method: oauth
      priority: interactive
      project: departure-archive
      threads: 5
      type: bigquery
  target: dev
```

You will also need to install poetry, create a Python 3.11+ virtual environment (you should consider using a Python version manager like pyenv), and then install the dbt requirements.

```bash
python -m pyenv env

source ./env/bin/activate

poetry install
```

## Data Pipelines
To run pipelines from your local machine, you should use dbt tags to make sure you don't spend more money than needed (see Saving Money on dbt below).

### Google Search Console
The Google Search Console pipeline merges the data from multiple Search Console BigQuery daily dumps into a single. To run the Google Search Console pipeline, run:

```bash
dbt build -s tag:google_search_console
```

### Ad Spend
The Ad Spend report merges the data from multiple Supemetric dumps to get the total daily ad spend per source (Google, Bing, etc.). This data is then combined with the daily agency fee spend and our demand partner daily spend to compute our total daily marketing spend. To run the Ad Spend report, run:

```bash
dbt build -s tag:ad_spend
```

## Troubleshooting
Some pipelines access Google Sheets (External tables). The default gcloud credentials won't allow you to access these tables from BigQuery. If you are receiving a `Access Denied: BigQuery BigQuery: Permission denied while getting Drive credentials.` error, you must login with additiional permissions:

```bash
gcloud auth application-default login --scopes=openid,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/sqlservice.login,https://www.googleapis.com/auth/drive
```

## Organizing your Code

The busbud-dbt project was configured to use dbt custom schemas with the [schema names by env variant](https://docs.getdbt.com/docs/build/custom-schemas#an-alternative-pattern-for-generating-schema-names).

When create a new dataset, we recommend that you create new folders in your dbt project with the same name as the dataset (for example `models/google_search_console`), set up a custom schema, and tags with the dataset name.

You can configure the custom schema and tags in the `dbt_project.yml` file in the root folder.
```yaml
models:
  busbud_dbt:
    +persist_docs:
      relation: true
      columns: true
    google_search_console:
      +tags: ["google_search_console"]
      +schema: google_search_console
      +materialized: table
```

## Saving Money on dbt

You should use [dbt selectors](https://docs.getdbt.com/reference/node-selection/syntax) when working on your local machine or scheduling your production pipelines. The default `dbt build` command will recreate your entire project, even the parts you're not working on.

If you set up your tags properly (see [Organizing your Code](#organizing-your-code) above), you can recreate your dataset without re-building the entire project with the following command:

```bash
dbt run --select tag:my_tag
```

## dbt Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
