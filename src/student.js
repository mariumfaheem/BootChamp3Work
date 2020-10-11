import React from 'react'

function Student(props){
  return(
    <div class="StudentText">
        <h1>Student Name is  {props.studentName}</h1>
   <h2>Student Name is  {props.studentMarks}</h2>

    </div>

  )

}
export default Student