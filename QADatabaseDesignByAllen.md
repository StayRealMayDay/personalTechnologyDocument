## user
nothing worth talk about

## search log

If anyone search answers in the Automatic Answer part. It will store the start time and end time of the whole process in the `search_log` table. During this process you can ask more than one question. All the question you asked will be stored in the `search_answer` table. So there is a one to many relationship between this two tables.

## sraech answer 

The `search_answer` table will store the question content and the asking time.

## knowledge

Knowledge is created by the user. It has a one to may relationship with the user. One user can create many knowledges.

## knowledge classfication

I note that each knowledge belong to a category. So there is a table named `knowledge_classfication` to store the classfication information. Clearly it has a one to may relationship with the knowledge. One category can have many knowledges.

## serchanswe has knowledge

I think that when we ask a question to the systme. It can help us find more than one knowledge to answer the question or there are more than one knowledge can answer this question(Note that the mean of this two descriptions are different.). So I user a `serchanswe_has_knowledge` table to store this information. It's a many to many relationship. Cause if there is a record in the `serchanswe_has_knowledge` table, there must exist the corresponding record in the `knowledge` table and `search_answer` table. So it's a indetifying relationship.

## score

User can score the knowledge, it's very clear that there is a many to many relationship between the user and knowledge. So I use `score` table to store it.

## community question

Community questions are created by users. So it has a one to many relationship with the user.

## community question answer

I user `community_question_answer` table to store the answer of the community questions. One user can answer many questions and one question can be answered by many users, so there is a many to many relationship between them. I use `community_question_answer` table to store it.

## collection

I use `collection` table to store the collection information of the users. Clearly it has a one to many relationship with user, knowledge and community question individully.

## comment

Very much like the `collection`. But in the system, one can comment one's comment, so it has a one to many relationship with itself.

## follow and fans

I use `follow_and_fans` to store the information of fans and follow. There are two one to many relationship wiht the `user` table. And I user two attributes `is_follow` and `is_fans` to store the two relationship between users individully.