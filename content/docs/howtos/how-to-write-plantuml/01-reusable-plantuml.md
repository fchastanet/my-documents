---
title: 'Reusable PlantUML Components: Modular Diagram Architecture and Shared Styling'
linkTitle: Reusable PlantUML Components
description: Learn how to create reusable PlantUML components for modular diagram architecture and shared styling across multiple diagrams.
type: docs
weight: 15
slug: reusable-plantuml-components-modular-diagram-architecture-shared-styling
date: '2026-03-31T19:00:00+01:00'
lastmod: '2026-05-10T23:42:08+02:00'
version: '1.1'
---

Today, we will explore how to create reusable PlantUML components for modular diagram architecture and shared styling
across multiple diagrams. This approach allows you to maintain consistency and reduce duplication in your PlantUML
diagrams.

## 1. Database ERD Examples: Music Domain

The `database/` directory contains a complete example of MongoDB Entity Relationship Diagrams modeling a **music
streaming recommendation system**. These examples demonstrate:

- **Modular diagram architecture** with reusable components
- **Subsection inclusion** using `!includesub` and `!startsub`
- **Shared styling** across multiple diagrams
- **JSON data structures** within PlantUML diagrams

### 1.1. Entity Collections

The music database example includes the following collections:

| File                                        | Description                                       |
| ------------------------------------------- | ------------------------------------------------- |
| `music-db-Playlists_Collections_ERD.puml`   | Playlist catalog and published playlist instances |
| `music-db-Moods_Collections_ERD.puml`       | Music mood taxonomy and user taste preferences    |
| `music-db-Suggestions_Collections_ERD.puml` | Playlist suggestion engine based on user moods    |
| `music-db-Logs.puml`                        | API usage logs for AI-generated playlist metadata |
| `music-db-All_collections.puml`             | **Master diagram** combining all collections      |
| `db_theme_standard.puml`                    | **Reusable theme** providing consistent styling   |

### 1.2. Business Logic Flow

1. **Playlists** are tagged with **moods** (e.g., "energetic", "chill", "melancholic")
2. **Users** express music preferences through **user_tastes** (preferred moods)
3. The **suggestion engine** matches playlists to users based on mood similarity
4. Vector embeddings enable semantic matching between user tastes and playlist moods

### 1.3. Complete Database Schema Overview

The following diagram shows all collections and their relationships:

![Music Database - All Collections](/docs/howtos/how-to-write-plantuml/database/music-db-All_collections.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-All_collections.puml)

{{< codeExpand src="database/music-db-All_collections.puml" lang="plantuml" title="View PlantUML source code" >}}

## 2. Reusable Styling with `db_theme_standard.puml`

The `db_theme_standard.puml` file is a **standalone, reusable theme definition** that ensures visual consistency across
all database diagrams.

### 2.1. Why Separate Styling?

Separating styling from content provides several benefits:

- **Single source of truth** for visual standards
- **Easy updates** - change once, apply everywhere
- **Reduced duplication** - no need to copy/paste styling rules
- **Clear separation** between diagram content and presentation

### 2.2. What It Defines

The reusable theme file defines:

```plantuml
!include content/docs/howtos/how-to-write-plantuml/database/db_theme_standard.puml
```

- **Visual styling**: fonts, colors, line styles, rounded corners
- **Notation macros**: `PK` (primary key), `FK` (foreign key), `IDX` (index)
- **Index types**: `UNIQUE`, `SPARSE`, `UNIQUE_SPARSE`
- **Legend symbols**: explaining all notation used in diagrams

Here's what the theme styling looks like:

![Database Theme Standard](/docs/howtos/how-to-write-plantuml/database/db_theme_standard.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/db_theme_standard.puml)

{{< codeExpand src="database/db_theme_standard.puml" lang="plantuml" title="View theme source code" >}}

### 2.3. Usage Pattern

Every database ERD diagram includes this file:

```plantuml
@startuml
!include content/docs/howtos/how-to-write-plantuml/database/db_theme_standard.puml

ENTITY users {
  PK _id : ObjectId
  --
  + IDX email : string
}
@enduml
```

This pattern ensures all diagrams share professional, consistent notation.

## 3. Modular Composition with `!startsub` and `!includesub`

PlantUML supports **subsection extraction**, allowing you to define reusable diagram fragments that can be included
selectively in other diagrams.

### 3.1. Defining Subsections: `!startsub`

Use `!startsub` and `!endsub` to mark reusable sections:

```plantuml
' Define a reusable playlist entity
!startsub PLAYLIST_MODEL
ENTITY playlists {
  PK _id : ObjectId
  + IDX reference_code : string
}
!endsub

' Define additional detail fields
!startsub PLAYLIST_MODEL_DETAILS
ENTITY playlists {
  # moods : ObjectId[]
  # title : string
  - created_at : datetime
}
!endsub
```

### 3.2. Including Subsections: `!includesub`

Use `!includesub` to import specific subsections into another diagram:

```plantuml
@startuml
!include db_theme_standard.puml

' Include only the core playlist model (without details)
!includesub music-db-Playlists_Collections_ERD.puml!PLAYLIST_MODEL

@enduml
```

### 3.3. Benefits of Subsection Inclusion

1. **Selective composition** - include only what you need
2. **Multiple levels of detail** - show high-level or detailed views
3. **Avoid duplication** - define entities once, reuse everywhere
4. **Maintainability** - update the source, all diagrams reflect changes

### 3.4. Example: Cross-Diagram References

In [music-db-Moods_Collections_ERD.puml](database/music-db-Moods_Collections_ERD.puml):

```plantuml
package "Playlist Collections" <<Only the relevant fields are shown>> #LightGray {
  !includesub content/docs/howtos/how-to-write-plantuml/database/music-db-Playlists_Collections_ERD.puml!PLAYLIST_MODEL
}
```

This imports the `playlists` entity definition without duplicating code, showing how moods relate to playlists.

#### 3.4.1. Example Diagrams

**Playlists Collections:**

![Music Database - Playlists Collections ERD](/docs/howtos/how-to-write-plantuml/database/music-db-Playlists_Collections_ERD.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-Playlists_Collections_ERD.puml)

{{< codeExpand src="database/music-db-Playlists_Collections_ERD.puml" lang="plantuml" title="View PlantUML source code"
\>}}

**Moods Collections:**

![Music Database - Moods Collections ERD](/docs/howtos/how-to-write-plantuml/database/music-db-Moods_Collections_ERD.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-Moods_Collections_ERD.puml)

{{< codeExpand src="database/music-db-Moods_Collections_ERD.puml" lang="plantuml" title="View PlantUML source code" >}}

**Suggestions Collections:**

![Music Database - Suggestions Collections ERD](/docs/howtos/how-to-write-plantuml/database/music-db-Suggestions_Collections_ERD.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-Suggestions_Collections_ERD.puml)

{{< codeExpand src="database/music-db-Suggestions_Collections_ERD.puml" lang="plantuml"

title="View PlantUML source code" >}}

## 4. Master Diagram: `music-db-All_collections.puml`

The [music-db-All_collections.puml](database/music-db-All_collections.puml) file demonstrates **diagram composition** by
combining all subsections into a complete database schema view.

### 4.1. How It Works

```plantuml
@startuml
!pragma layout smetana
!include content/docs/howtos/how-to-write-plantuml/database/db_theme_standard.puml

' Include playlist entities
!includesub content/docs/howtos/how-to-write-plantuml/database/music-db-Playlists_Collections_ERD.puml!PLAYLIST_MODEL
!includesub content/docs/howtos/how-to-write-plantuml/database/music-db-Playlists_Collections_ERD.puml!PLAYLIST_MODEL_DETAILS

' Include mood entities
!includesub content/docs/howtos/how-to-write-plantuml/database/music-db-Moods_Collections_ERD.puml!MODEL_MOOD
!includesub content/docs/howtos/how-to-write-plantuml/database/music-db-Moods_Collections_ERD.puml!MODEL_MOOD_DETAILS

' ... and so on for all collections
@enduml
```

### 4.2. Advantages

- **Single comprehensive view** of the entire database
- **No code duplication** - entities defined once in source files
- **Automatic updates** - changes propagate from source diagrams
- **Flexible composition** - easily add/remove collections

This pattern is perfect for creating both **detailed individual diagrams** and **high-level overview diagrams** from the
same source.

#### 4.2.1. Master Diagram View

![Music Database - All Collections](/docs/howtos/how-to-write-plantuml/database/music-db-All_collections.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-All_collections.puml)

{{< codeExpand src="database/music-db-All_collections.puml" lang="plantuml" title="View complete PlantUML source code"
\>}}

## 5. JSON Data Structures in PlantUML

PlantUML supports embedding **JSON notation** directly in diagrams, useful for documenting:

- API request/response structures
- Database document schemas (MongoDB)
- Configuration examples
- Data transformation flows

### 5.1. Example from `music-db-Logs.puml`

```plantuml
json payload as "**Payload Example**" {
  "**field**": "title",
  "**value**": "Summer Vibes Mix",
  "**fallback_locale**": "en-US"
}
music_api_logs -r-> payload: payload
```

This creates a formatted JSON box linked to an entity, showing exactly what data structure is used.

### 5.2. Complete Document Example

The logs diagram also shows a **complete MongoDB document**:

```plantuml
json complete_example as "**Complete Document Example**" {
    "**_id**": "698ddd946f3bad1915a67e87",
    "**instance_urn**": "urn:music:spotify",
    "**user_urn**": "urn:music:spotify:user/...",
    "**tag**": "music-ai.playlist_metadata.generate",
    "**payload**": {
        "**field**": "description",
        "**playlist_title**": "Acoustic Coffee House",
        "**additional_metadata**": { "..." }
    },
    "**prediction**": ["..."]
}
```

### 5.3. Benefits

- **Precise schema documentation** alongside ERD diagrams
- **Visual clarity** - readers see exact data structures
- **Version control** - schema examples tracked with diagrams
- **Testing reference** - developers can use examples for test data

### 5.4. Complete Logs Diagram Example

Here's the complete logs diagram showing JSON structures and their relationships:

![Music Database - Logs](/docs/howtos/how-to-write-plantuml/database/music-db-Logs.svg)

[View source on GitHub](https://github.com/fchastanet/my-documents/tree/master/content/docs/howtos/how-to-write-plantuml/database/music-db-Logs.puml)

{{< codeExpand src="database/music-db-Logs.puml" lang="plantuml" title="View PlantUML source code" >}}
