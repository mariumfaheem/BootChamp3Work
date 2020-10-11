import React from 'react';
import './App.css'
import Dinner from './dinner'
import Student from './student'

export default function App(){
  //or props jo h call k sth / se phle lkhna hoga
  return(
    <div className="center">
     <h1>Menu</h1>
     <Dinner  dishName="Biryani" sweet="Kheer" />
     <hr></hr>
     <Dinner dishName="nihari" sweet="Kajar ka halwa" /> 
     <hr></hr>
     <Dinner  dishName="Karahi"  sweet="Jaleebi" />
  <hr/>

     <Student studentName="Marium" studentMarks="22" />
    </div>
    


  )
}



//export default App;
