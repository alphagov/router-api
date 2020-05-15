desc "Delete Html Attachments"
task delete_html_attachments: :environment do
  ids = [1_078_124, 1_078_163, 1_083_418, 1_104_517, 1_170_936, 1_170_993, 1_172_070, 1_198_611, 1_203_580, 1_203_664, 1_208_452, 1_248_948, 1_253_466, 1_294_793, 1_310_784, 1_317_549, 1_345_389, 1_345_867, 1_352_217, 1_373_344, 1_382_498, 1_394_972, 1_401_181, 1_408_550, 1_418_705, 1_421_050, 1_422_548, 1_424_141, 1_424_550, 1_425_204, 1_429_699, 1_429_820, 1_432_602, 1_435_800, 1_435_903, 1_436_477, 1_436_860, 1_451_010, 1_452_262, 1_455_301, 1_474_071, 1_474_742, 1_479_015, 1_489_722, 1_504_843, 1_504_844, 1_504_845, 1_504_846, 1_504_847, 1_504_848, 1_504_849, 1_504_850, 1_504_851, 1_511_969, 1_513_514, 1_515_425, 1_515_811, 1_516_072, 1_517_966, 1_518_274, 1_519_140, 1_540_240, 1_551_466, 1_552_281, 1_554_790, 1_557_901, 1_562_114, 1_573_343, 1_579_433, 1_580_104, 1_580_720, 1_581_028, 1_581_824, 1_584_179, 1_584_542, 1_586_814, 1_588_529, 1_588_590, 1_589_121, 1_590_665, 1_591_196, 1_591_400, 1_592_473, 1_592_475, 1_594_396, 1_598_558, 1_599_799, 1_601_922, 1_605_927, 1_606_687, 1_606_963, 1_609_908, 1_610_160, 1_611_523, 1_611_686, 1_613_943, 1_614_963, 1_615_431, 1_622_682, 1_623_756, 1_624_869, 1_630_252, 1_632_270, 1_632_289, 1_638_851, 1_639_490, 1_640_442, 1_640_458, 1_640_479, 1_640_500, 1_640_502, 1_640_742, 1_641_582, 1_648_225, 1_649_329, 1_649_540, 1_649_542, 1_656_571, 1_661_762, 1_666_083, 1_667_620, 1_668_721, 1_671_818, 1_671_823, 1_677_726, 1_681_088, 1_681_979, 1_682_009, 1_690_665, 1_690_951, 1_693_326, 1_693_328, 1_694_496, 1_697_360, 1_697_533, 1_700_838, 1_706_257, 1_706_261, 1_707_171, 1_717_831, 1_718_440, 1_732_007, 1_732_011, 1_732_026, 1_732_036, 1_732_045, 1_741_516, 1_746_296, 1_751_401, 1_752_682, 1_753_749, 1_757_924, 1_758_667, 1_766_280, 1_766_302, 1_768_969, 1_768_980, 1_768_982, 1_768_988, 1_772_452, 1_772_999, 1_775_287, 1_783_387, 1_783_668, 1_783_967, 1_784_276, 1_790_843, 1_792_307, 1_793_146, 1_800_081, 1_805_260, 1_805_305, 1_806_223, 1_812_920, 1_816_634, 1_817_426, 1_817_568, 1_820_649, 1_829_242, 1_830_047, 1_833_226, 1_843_785, 1_849_934, 1_857_466, 1_862_175, 1_865_281, 1_866_272, 1_873_683, 1_874_295, 1_874_498, 1_876_924, 1_893_526]
  paths = /\/government\/publications\/[a-zA-Z0-9\-]\/(#{ids.join("|")})/

  delete_routes(paths)
end

desc "Delete Collections"
task delete_collections: :environment do
  paths = ["/government/collections/ad-hoc-statistical-analysis-2015-quarter-1", "/government/collections/cde-marketplace-5-february-2015-exhibitor-case-studies", "/government/collections/chapter-32-port-cases-involving-prosecution-immigration-directorate-instructions", "/government/collections/command-papers", "/government/collections/departmental-exceptions-to-spending-controls-2014", "/government/collections/electronic-business-commissioners-directions", "/government/collections/flagging-up-newsletters", "/government/collections/green-deal-quick-guides", "/government/collections/greenhouse-gas-conversion-factors-for-company-reporting", "/government/collections/guidance-on-british-citizenship", "/government/collections/house-of-commons-papers", "/government/collections/ministerial-gifts-hospitality-travel-and-meetings-2012", "/government/collections/ministerial-gifts-hospitality-travel-and-meetings-2013", "/government/collections/national-curriculum-assessments-2013", "/government/collections/official-documents", "/government/collections/oisc-news", "/government/collections/self-assessment-helpsheets-additional-information", "/government/collections/social-care-online-questionnaires-2015", "/government/collections/think-act-report-sign-ups-and-case-studies"]

  delete_routes(paths)
end

desc "Test delete Html Attachments"
task test_html_attachments: :environment do
  ids = [1_078_124, 1_078_163, 1_083_418, 1_104_517, 1_170_936, 1_170_993, 1_172_070, 1_198_611, 1_203_580, 1_203_664, 1_208_452, 1_248_948, 1_253_466, 1_294_793, 1_310_784, 1_317_549, 1_345_389, 1_345_867, 1_352_217, 1_373_344, 1_382_498, 1_394_972, 1_401_181, 1_408_550, 1_418_705, 1_421_050, 1_422_548, 1_424_141, 1_424_550, 1_425_204, 1_429_699, 1_429_820, 1_432_602, 1_435_800, 1_435_903, 1_436_477, 1_436_860, 1_451_010, 1_452_262, 1_455_301, 1_474_071, 1_474_742, 1_479_015, 1_489_722, 1_504_843, 1_504_844, 1_504_845, 1_504_846, 1_504_847, 1_504_848, 1_504_849, 1_504_850, 1_504_851, 1_511_969, 1_513_514, 1_515_425, 1_515_811, 1_516_072, 1_517_966, 1_518_274, 1_519_140, 1_540_240, 1_551_466, 1_552_281, 1_554_790, 1_557_901, 1_562_114, 1_573_343, 1_579_433, 1_580_104, 1_580_720, 1_581_028, 1_581_824, 1_584_179, 1_584_542, 1_586_814, 1_588_529, 1_588_590, 1_589_121, 1_590_665, 1_591_196, 1_591_400, 1_592_473, 1_592_475, 1_594_396, 1_598_558, 1_599_799, 1_601_922, 1_605_927, 1_606_687, 1_606_963, 1_609_908, 1_610_160, 1_611_523, 1_611_686, 1_613_943, 1_614_963, 1_615_431, 1_622_682, 1_623_756, 1_624_869, 1_630_252, 1_632_270, 1_632_289, 1_638_851, 1_639_490, 1_640_442, 1_640_458, 1_640_479, 1_640_500, 1_640_502, 1_640_742, 1_641_582, 1_648_225, 1_649_329, 1_649_540, 1_649_542, 1_656_571, 1_661_762, 1_666_083, 1_667_620, 1_668_721, 1_671_818, 1_671_823, 1_677_726, 1_681_088, 1_681_979, 1_682_009, 1_690_665, 1_690_951, 1_693_326, 1_693_328, 1_694_496, 1_697_360, 1_697_533, 1_700_838, 1_706_257, 1_706_261, 1_707_171, 1_717_831, 1_718_440, 1_732_007, 1_732_011, 1_732_026, 1_732_036, 1_732_045, 1_741_516, 1_746_296, 1_751_401, 1_752_682, 1_753_749, 1_757_924, 1_758_667, 1_766_280, 1_766_302, 1_768_969, 1_768_980, 1_768_982, 1_768_988, 1_772_452, 1_772_999, 1_775_287, 1_783_387, 1_783_668, 1_783_967, 1_784_276, 1_790_843, 1_792_307, 1_793_146, 1_800_081, 1_805_260, 1_805_305, 1_806_223, 1_812_920, 1_816_634, 1_817_426, 1_817_568, 1_820_649, 1_829_242, 1_830_047, 1_833_226, 1_843_785, 1_849_934, 1_857_466, 1_862_175, 1_865_281, 1_866_272, 1_873_683, 1_874_295, 1_874_498, 1_876_924, 1_893_526]
  paths = /\/government\/publications\/[a-zA-Z0-9\-]\/(#{ids.join("|")})/

  puts_routes_count(paths)
end

desc "Test delete Collections"
task test_delete_collections: :environment do
  paths = ["/government/collections/ad-hoc-statistical-analysis-2015-quarter-1", "/government/collections/cde-marketplace-5-february-2015-exhibitor-case-studies", "/government/collections/chapter-32-port-cases-involving-prosecution-immigration-directorate-instructions", "/government/collections/command-papers", "/government/collections/departmental-exceptions-to-spending-controls-2014", "/government/collections/electronic-business-commissioners-directions", "/government/collections/flagging-up-newsletters", "/government/collections/green-deal-quick-guides", "/government/collections/greenhouse-gas-conversion-factors-for-company-reporting", "/government/collections/guidance-on-british-citizenship", "/government/collections/house-of-commons-papers", "/government/collections/ministerial-gifts-hospitality-travel-and-meetings-2012", "/government/collections/ministerial-gifts-hospitality-travel-and-meetings-2013", "/government/collections/national-curriculum-assessments-2013", "/government/collections/official-documents", "/government/collections/oisc-news", "/government/collections/self-assessment-helpsheets-additional-information", "/government/collections/social-care-online-questionnaires-2015", "/government/collections/think-act-report-sign-ups-and-case-studies"]

  puts_routes_count(paths)
end

def delete_routes(paths)
  routes = Route.where(incoming_path: paths, backend_id: "whitehall-frontend")
  if routes.any?
    puts "Deleting: #{routes.pluck(:incoming_path).join(', ')}"
    routes.destroy_all
    RouterReloader.reload
    puts "Done."
  else
    puts "No routes found."
  end
end

def puts_routes_count(paths)
  routes = Route.where(incoming_path: paths, backend_id: "whitehall-frontend")
  puts "You are going to delete #{routes.count} routes"
end
