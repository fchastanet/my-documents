const defaultFields = [
  // SEO
  {
    title: "SEO",
    name: "sectionSEO",
    description: "Fields related to SEO (Search Engine Optimization).",
    type: "heading"
  },
  {
    title: "title",
    name: "title",
    type: "string",
    single: true,
    default: "{{title}}",
    required: true
  },
  {
    title: "linkTitle",
    name: "linkTitle",
    type: "string",
    single: true,
    description: "The title used for links. If not set, the title will be used.",
    required: false
  },
  {
    title: "Slug",
    name: "slug",
    type: "string",
    single: true,
    description: "The slug used for the URL. If not set, the filename will be used.",
    default: "{{slug}}",
    required: false
  },
  {
    title: "description",
    name: "description",
    type: "string",
    required: true
  },
  {
    title: "Page info",
    name: "pageInfo",
    description: "Description of the page that will be displayed using pageinfo shortcode.",
    wysiwyg: 'markdown',
    type: "string",
    required: false
  },

  // Categorization
  {
    title: "Categorization",
    name: "sectionCategorization",
    description: "Fields related to categorization and metadata.",
    type: "heading"
  },
  {
    title: "categories",
    name: "categories",
    type: "categories"
  },
  {
    title: "tags",
    name: "tags",
    type: "tags"
  },

  // Metadata
  {
    title: "Metadata",
    name: "sectionMetadata",
    type: "heading"
  },
  {
    title: "draft",
    name: "draft",
    type: "boolean",
    default: false,
    description: "Whether this content is a draft. Drafts are not published and can be used for work in progress.",
    single: true
  },
  {
    title: "date",
    name: "date",
    type: "datetime",
    default: "{{now}}",
    isPublishDate: false,
    isModifiedDate: false,
    single: true,
    required: true
  },
  {
    title: "lastmod",
    name: "lastmod",
    type: "datetime",
    isPublishDate: true,
    isModifiedDate: true,
    single: true,
    required: true
  },
  {
    title: "version",
    name: "version",
    type: "string",
    default: "1.0",
    single: true,
    required: true
  },
];

const optionalFields = [
  {
    title: "Optional Fields",
    name: "sectionOptionalFields",
    type: "heading"
  },
  {
    title: "Preview Image",
    name: "previewImage",
    type: "image"
  },
  {
    title: "Icon",
    name: "icon",
    type: "string",
    single: true,
    description: "The icon used for this content. (Eg: 'fa-solid fa-brain')",
    default: "",
    required: false
  },
  {
    title: "Layout",
    name: "layout",
    type: "string",
    single: true,
    description: "The layout used for this content. If not set, the default layout will be used.",
    default: "",
    required: false
  },
  {
    title: "Type",
    name: "type",
    type: "string",
    single: true,
    description: "The type of content. This can be used to differentiate between different types of content, such as docs, tutorials, etc.",
    default: "",
    required: false
  },
  {
    title: "Weight",
    name: "weight",
    type: "number",
    required: false,
    numberOptions: {
      min: 1,
      max: 100,
      step: 1
    }
  },
  {
    title: "Sidebar Root For",
    name: "sidebar_root_for",
    type: "string",
    single: true,
    description: "`sidebar_root_for` parameter set in section with two values:\n- `children`: Rooted sidebar shown only for descendant pages\n- `self`: Rooted sidebar shown for the section itself and all descendants\n- Nested sidebar_root_for sections are supported: descendant pages use the\n  closest ancestor with `sidebar_root_for` set",
    default: "",
    required: false
  }
];

const backupFields = [
  {
    title: "backup",
    name: "backup",
    type: "fields",
    fields: [
      {
        title: "author",
        name: "author",
        type: "string",
        single: true,
      },
      {
        title: "authorUrl",
        name: "authorUrl",
        type: "string",
        single: true,
      },
      {
        title: "originalUrl",
        name: "originalUrl",
        type: "string",
        single: true,
        required: true
      },
      {
        title: "date",
        name: "date",
        type: "datetime",
        single: true,
        required: true
      }
    ]
  },
];

module.exports = async (config) => {
  return {
    ...config,
    "frontMatter.taxonomy.contentTypes": [
      {
        "name": "default",
        "pageBundle": true,
        "previewPath": null,
        "fields": [
          ...defaultFields,
          ...optionalFields
        ]
      },
      {
        "name": "backup",
        "pageBundle": true,
        "previewPath": null,
        "fields": [
          ...defaultFields,
          ...optionalFields,
          ...backupFields
        ]
      }
    ],
  }
};
