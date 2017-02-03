desc "Delete Html Attachments"
task delete_html_attachments: :environment do
  ids = [1078124, 1078163, 1083418, 1104517, 1170936, 1170993, 1172070, 1198611, 1203580, 1203664, 1208452, 1248948, 1253466, 1294793, 1310784, 1317549, 1345389, 1345867, 1352217, 1373344, 1382498, 1394972, 1401181, 1408550, 1418705, 1421050, 1422548, 1424141, 1424550, 1425204, 1429699, 1429820, 1432602, 1435800, 1435903, 1436477, 1436860, 1451010, 1452262, 1455301, 1474071, 1474742, 1479015, 1489722, 1504843, 1504844, 1504845, 1504846, 1504847, 1504848, 1504849, 1504850, 1504851, 1511969, 1513514, 1515425, 1515811, 1516072, 1517966, 1518274, 1519140, 1540240, 1551466, 1552281, 1554790, 1557901, 1562114, 1573343, 1579433, 1580104, 1580720, 1581028, 1581824, 1584179, 1584542, 1586814, 1588529, 1588590, 1589121, 1590665, 1591196, 1591400, 1592473, 1592475, 1594396, 1598558, 1599799, 1601922, 1605927, 1606687, 1606963, 1609908, 1610160, 1611523, 1611686, 1613943, 1614963, 1615431, 1622682, 1623756, 1624869, 1630252, 1632270, 1632289, 1638851, 1639490, 1640442, 1640458, 1640479, 1640500, 1640502, 1640742, 1641582, 1648225, 1649329, 1649540, 1649542, 1656571, 1661762, 1666083, 1667620, 1668721, 1671818, 1671823, 1677726, 1681088, 1681979, 1682009, 1690665, 1690951, 1693326, 1693328, 1694496, 1697360, 1697533, 1700838, 1706257, 1706261, 1707171, 1717831, 1718440, 1732007, 1732011, 1732026, 1732036, 1732045, 1741516, 1746296, 1751401, 1752682, 1753749, 1757924, 1758667, 1766280, 1766302, 1768969, 1768980, 1768982, 1768988, 1772452, 1772999, 1775287, 1783387, 1783668, 1783967, 1784276, 1790843, 1792307, 1793146, 1800081, 1805260, 1805305, 1806223, 1812920, 1816634, 1817426, 1817568, 1820649, 1829242, 1830047, 1833226, 1843785, 1849934, 1857466, 1862175, 1865281, 1866272, 1873683, 1874295, 1874498, 1876924, 1893526]
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
  ids = [1078124, 1078163, 1083418, 1104517, 1170936, 1170993, 1172070, 1198611, 1203580, 1203664, 1208452, 1248948, 1253466, 1294793, 1310784, 1317549, 1345389, 1345867, 1352217, 1373344, 1382498, 1394972, 1401181, 1408550, 1418705, 1421050, 1422548, 1424141, 1424550, 1425204, 1429699, 1429820, 1432602, 1435800, 1435903, 1436477, 1436860, 1451010, 1452262, 1455301, 1474071, 1474742, 1479015, 1489722, 1504843, 1504844, 1504845, 1504846, 1504847, 1504848, 1504849, 1504850, 1504851, 1511969, 1513514, 1515425, 1515811, 1516072, 1517966, 1518274, 1519140, 1540240, 1551466, 1552281, 1554790, 1557901, 1562114, 1573343, 1579433, 1580104, 1580720, 1581028, 1581824, 1584179, 1584542, 1586814, 1588529, 1588590, 1589121, 1590665, 1591196, 1591400, 1592473, 1592475, 1594396, 1598558, 1599799, 1601922, 1605927, 1606687, 1606963, 1609908, 1610160, 1611523, 1611686, 1613943, 1614963, 1615431, 1622682, 1623756, 1624869, 1630252, 1632270, 1632289, 1638851, 1639490, 1640442, 1640458, 1640479, 1640500, 1640502, 1640742, 1641582, 1648225, 1649329, 1649540, 1649542, 1656571, 1661762, 1666083, 1667620, 1668721, 1671818, 1671823, 1677726, 1681088, 1681979, 1682009, 1690665, 1690951, 1693326, 1693328, 1694496, 1697360, 1697533, 1700838, 1706257, 1706261, 1707171, 1717831, 1718440, 1732007, 1732011, 1732026, 1732036, 1732045, 1741516, 1746296, 1751401, 1752682, 1753749, 1757924, 1758667, 1766280, 1766302, 1768969, 1768980, 1768982, 1768988, 1772452, 1772999, 1775287, 1783387, 1783668, 1783967, 1784276, 1790843, 1792307, 1793146, 1800081, 1805260, 1805305, 1806223, 1812920, 1816634, 1817426, 1817568, 1820649, 1829242, 1830047, 1833226, 1843785, 1849934, 1857466, 1862175, 1865281, 1866272, 1873683, 1874295, 1874498, 1876924, 1893526]
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
