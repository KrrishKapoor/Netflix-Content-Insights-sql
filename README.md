# Netflix Content Insights (SQL Case Study)

## Background and Overview

Netflix, as one of the world's largest streaming platforms, offers a vast catalog of TV shows and movies across regions, genres, and formats. This SQL case study explores Netflix's content metadata with the goal of deriving actionable insights that could inform content acquisition, localization, and strategy teams.

The analysis simulates the type of work a junior data analyst might perform in a content strategy or business intelligence role, focusing on how to structure queries, communicate findings clearly, and deliver business value from raw data.

Key business questions addressed:
- What genres are most dominant?
- Which countries contribute the most content?
- Are TV shows becoming more common than movies?
- How are actor appearances distributed by country?
- What content carries darker or more mature themes based on descriptions?

## Data Structure Overview

The dataset consists of one table (`netflix`) with 12 columns:

- `show_id` (string): Unique ID per title
- `type` (string): Movie or TV Show
- `title` (string): Name of the show/movie
- `director` (string): Director(s)
- `cast` (string): Cast list (comma-separated)
- `country` (string): Country or countries of production
- `date_added` (string): When the title was added to Netflix
- `release_year` (int): Year of original release
- `rating` (string): Content rating (e.g., PG, R)
- `duration` (string): Runtime or number of seasons
- `listed_in` (string): Genre/category tags (comma-separated)
- `description` (string): Short content summary

No joins were needed; all logic was built with filtering, aggregation, window functions, string parsing, and date handling.

## Executive Summary

Over the last decade, Netflix's content catalog has expanded significantly, with a clear shift in regional diversity and genre mix. The U.S. and India dominate content volume, while TV Shows have grown rapidly in the last five years. Action, International, and Drama genres lead in popularity, and content involving themes like "kill" or "violence" made up over 10% of the catalog. A label-based scan of descriptions helped tag mature content using simple text logic.

Key summary findings:
- India and the U.S. are top content-producing countries.
- TV Shows are catching up to Movies in volume.
- Actor "Adam Sandler" appeared in multiple recent titles, but fewer than expected.
- Genres like Documentaries and Dramas dominate TV Shows; Movies skew toward Action.
- Content descriptions containing violent or crime-related terms were flagged and quantified.

## Insights Deep Dive

### 1. Top Contributing Countries:
We split the multi-country column and found the U.S., India, and the U.K. as the top contributors.

### 2. TV vs. Movie Trends Over Time:
Using `release_year` and `type`, we plotted a pivot table that showed Movies historically dominated, but TV Shows have increased in recent years.

### 3. Most Common Genres:
By splitting `listed_in` and grouping by `type`, we found Drama, International, and Documentary genres appearing most frequently.

### 4. Actor Frequency by Country:
We extracted individual actor names from the `cast` column and counted appearances. This was done specifically for India, the U.S., and Canada.

### 5. Content Labeling (Intense vs. Light):
Descriptions were scanned for keywords like "kill", "violence", "drug", "war", and "murder" using regex to avoid false matches (e.g., "skilled"). Content was labeled accordingly:
- 12.6% labeled as Intense
- 87.4% labeled as Light

### 6. Average Duration by Genre (Movies):
We extracted the number from `duration`, grouped by individual genres, and found:
- Action movies average ~115 min
- Documentaries are often under 90 min
- Drama and Thriller genres average in the 100–115 min range

### 7. Longest-Running TV Shows:
Using `duration` like "9 Seasons", we ranked TV Shows by season count to find the longest-running titles.

### 8. International Collaborations:
By checking for commas in the `country` field, we counted all titles made via international co-production.

## Recommendations

- For Content Strategy: Leverage genre and country trends to prioritize licensing or production partnerships in India and other top-performing countries.
- For Localization Teams: Focus subtitle/dubbing efforts on top cross-border genres like International Dramas and Documentaries.
- For Editorial/UX: Highlight "Long-running Series" and "Dark Theme" categories as personalized carousels.
- For Compliance or Regional Review: Monitor flagged "Intense" content to ensure regional content rating alignment.

## Caveats and Assumptions

- `duration` values for TV Shows were not normalized; edge cases like "Part 1" were ignored.
- Keyword-based labeling uses simple pattern matching — not NLP or context-aware classification.
- `country`, `cast`, and `listed_in` fields are comma-separated strings, which can introduce duplication when unnested.
- Some descriptions are vague or missing; we excluded NULLs in those cases.

## For Recruiters

This project simulates a business-facing SQL analysis workflow:
- Cleaned and pre-processed data using SQL (handling NULLs, multi-value fields)
- Wrote complex queries with aggregation, filtering, ranking, text logic, and date parsing
- Delivered clearly defined insights, just like in a real stakeholder-facing report

All queries are stored in `netflix_queries.sql`. Let me know if you'd like to see this project extended into Tableau dashboards or joined with external viewership datasets.

