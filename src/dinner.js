import React from 'react'

//props is a object of function argument
function Dinner(props){
    return(
  <div>
<h1>Today we are serving {props.dishName} </h1>
<h2>Today sweet Dish is {props.sweet}</h2>

</div>
    )

}

export default Dinner