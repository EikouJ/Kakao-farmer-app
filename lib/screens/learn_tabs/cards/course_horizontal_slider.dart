import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/details/Tag.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/details/course_detail_page.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/details/courses_data.dart';

class CourseHorizontalSlider extends StatelessWidget {
  const CourseHorizontalSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: coursesData.length,
        itemBuilder: (BuildContext context, int index) {
          return CourseTile(
              courseId: coursesData[index].courseId,
              imageURL: coursesData[index].imageUrl,
              rating: coursesData[index].rating,
              title: coursesData[index].courseTitle,
              instructor: coursesData[index].instructor,
              price: coursesData[index].price,
              isBookmarked: coursesData[index].isBookmarked,
              tagTitle: coursesData[index].courseTag);
        },
      ),
    );
  }
}

class CourseTile extends StatelessWidget {
  String? courseId;
  final String imageURL;
  final String rating;
  final String title;
  final String instructor;
  final String price;
  final bool isBookmarked;
  final String tagTitle;
  Widget child;

  CourseTile(
      {super.key,
      required this.courseId,
      required this.imageURL,
      required this.rating,
      required this.title,
      required this.instructor,
      required this.price,
      required this.isBookmarked,
      required this.tagTitle,
      this.child = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8, right: 5),
              constraints: const BoxConstraints.expand(height: 150, width: 250),
              padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: AssetImage(imageURL), fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 10,
                    child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              rating,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(
                              IconlyBold.star,
                              size: 15,
                              color: Colors.yellow[800],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              instructor,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.yellow[900],
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 5,
                ),
                Tag(title: tagTitle)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
