context("country_list")

test_that("Arguments are handled correctly", {
  # Argument country
  expect_error(country_list(country=NA),
               info="Using NA for country code should raise an error")
  expect_error(country_list(country=NULL),
               info="Using NULL for country code should raise an error")
})

# test_that("API values sane", {
#   
#   # Should return a dataframe
#   expect_is(country_list(cache=FALSE), "data.frame", 
#             "Should return a dataframe")
#   # Check dimensions
#   expect_equivalent(ncol(country_list(cache=FALSE)), 9,
#                     "Invalid number of columns returned")
#   expect_equivalent(nrow(country_list(cache=FALSE)), 242,
#                     "Invalid number of countries returned")
#   
# })

#context("country_species_count")
#
#test_that("Arguments are handled correctly", {
#  # Argument country
#  expect_error(country_species_count(country=NA),
#               info="Using NA for country code should raise an error")
#  expect_error(country_species_count(country=NULL),
#               info="Using NULL for country code should raise an error")
#})

# test_that("API values sane", {
#   
#   # Expect an integer
#   expect_is(country_species_count(country="Finland", rlstatus="DD",
#                                   cache=FALSE), "integer")
#   
#   # Slightly pointless check since we don't (and don't want to) check 
#   # all the possible country/rlstatus combinations
#   expect_equal(country_species_count(country="Finland", rlstatus="DD",
#                                      cache=FALSE), 4)
#   expect_equal(country_species_count(country="Finland", rlstatus="EW",
#                                      cache=FALSE), 0)
#   expect_equal(country_species_count(country="Finland", rlstatus="EX",
#                                      cache=FALSE), 0)
#   expect_equal(country_species_count(country="Finland", rlstatus="DD",
#                                      cache=FALSE), 4)
#   expect_equal(country_species_count(country="Finland", rlstatus="LC",
#                                      cache=FALSE), 318)
#   expect_equal(country_species_count(country="Finland", rlstatus="NT",
#                                      cache=FALSE), 13)
#   expect_equal(country_species_count(country="Finland", rlstatus="VU",
#                                      cache=FALSE), 7)
#   expect_equal(country_species_count(country="Finland", rlstatus="EN",
#                                      cache=FALSE), 0)
#   expect_equal(country_species_count(country="Finland", rlstatus="CR",
#                                      cache=FALSE), 1)
#   # All species
#   expect_equal(country_species_count(country="Finland"), 343)
# })

# test_that("Cache works", {
#   
#   # Cache the response
#   suppressMessages(cached_1 <- country_species_count(country="Finland", 
#                                                      rlstatus="LC",
#                                                      cache=TRUE))
#   # Ignore the cache
#   fresh_data <- country_species_count(country="Finland", rlstatus="LC",
#                                       cache=FALSE)
#   # Load from cache and compare to the previous data
#   suppressMessages(cached_2 <- country_species_count(country="Finland", 
#                                                      rlstatus="LC",
#                                                      cache=TRUE))
#   expect_identical(cached_1, cached_2,
#                    "Cached values should be the same")
#   # Compare to the fresh data
#   expect_identical(cached_1, fresh_data,
#                    "Cached and fresh values should be the same")
# })

context("country_species_list")

test_that("Arguments are handled correctly", {
  # Argument country
  expect_error(country_species_list(country=NA),
               info="Using NA for country code should raise an error")
  expect_error(country_species_list(country=NULL),
               info="Using NULL for country code should raise an error")
})

test_that("API values sane", {
  
  kiwi.species <- country_species_list(country="New Zealand", cache=FALSE)
  
  # Use New Zealand (country code = 554).
  # First get all species and check the number
  expect_equal(nrow(kiwi.species), 608)
  # Test some values/species. Let's take California quail
  spp <- kiwi.species[104,]
  expect_equivalent(spp$iucn_species_id, 22679603,
                   info = "California quail IUCN species ID is wrong")
  expect_equivalent(spp$taxon, "Callipepla californica",
                    info = "California quail taxon is wrong")
  expect_equivalent(spp$kingdom, "Animalia",
                    info = "California quail kingdom is wrong")
  expect_equivalent(spp$phylum, "Chordata",
                    info = "California quail phylum is wrong")
  expect_equivalent(spp$class, "Aves",
                    info = "California quail class is wrong")
  expect_equivalent(spp$order, "Galliformes",
                    info = "California quail order is wrong")
  expect_equivalent(spp$family, "Odontophoridae",
                    info = "California quail order is wrong")
  expect_equivalent(spp$status, "LC",
                    info = "California quail IUCN status is wrong")
  expect_equivalent(spp$commonname, "California Quail",
                    info = "California quail common name is wrong")
  expect_equivalent(spp$language, "english",
                    info = "California quail assessment language is wrong")
  expect_equivalent(spp$country_id, 554,
                    info = "Country ISO code not correct")
  expect_equivalent(spp$country_name, "New Zealand",
                    info = "Country name code not correct")
  
  # Test the rlstatus argument
  kiwi.species.cr <- country_species_list(country="New Zealand", status="CR",
                                          cache=FALSE)
  expect_equal(nrow(kiwi.species.cr), 12)
  kiwi.species.cr.en <- country_species_list(country="New Zealand", 
                                             status=c("CR", "EN"),
                                             cache=FALSE)
  expect_equal(nrow(kiwi.species.cr.en), 48)
  
})

context("country_species_stats")

test_that("Arguments are handled correctly", {
  # Argument country
  expect_error(country_stats(country=NA),
               info="Using NA for country code should raise an error")
  expect_error(country_stats(country=NULL),
               info="Using NULL for country code should raise an error")
})

#test_that("API values sane", {
#  
#  # Get test data from Japan
#  japan.stats <- country_stats(country="Japan", cache=FALSE)
  
  # Stats should include 10 categories
#  expect_equal(nrow(japan.stats), 10)
  
#})

context("pa_country_stats")

test_that("Arguments are handled correctly", {
  # Argument country
  expect_error(pa_country_stats(country_id=NA),
               info="Using NA for country code should raise an error")
  expect_error(pa_country_stats(country_id=NULL),
               info="Using NULL for country code should raise an error")
})

test_that("API values sane", {
  
  # Only test for an individual PA within a country, testing for all would
  # be tedious. Also, don't test the WKT MULTIPOLYGON.
  
  # Get test data from Uganda
  uganda.stats <- pa_country_stats(country="Uganda", cache=FALSE)
  expect_is(uganda.stats, "data.frame",
            "Returned object is not a data frame")

  # Stats should include 10 categories
  expect_equal(dim(uganda.stats), c(58, 20),
               info="Dimensions for returned data frame are incorrect")
  # Check a single PA
  pian_upe <- uganda.stats[3,]
  expect_equivalent(pian_upe$wdpaid, 1435,
                    info = "WDPAID for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$iucn_cat, "III",
                    info = "IUCN category for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$extent, "34.2144200000001,1.52357000000006,34.7992400000001,2.25289000000009",
                    info = "Extent for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$name, "Pian Upe",
                    info = "Name for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$area, 2154,
                    info = "Area for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$pi, 14.45,
                    info = "PI for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$ap, 43.27,
                    info = "AP for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$gis_area, 2154,
                    info = "GIS area for Pian Upe (Uganda) is wrong")
  expect_equivalent(pian_upe$numterrsegms, 3.39,
                    info = "NUMTERRSEGMS for Pian Upe (Uganda) is wrong")
})
