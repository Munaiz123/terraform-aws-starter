module.exports.handler = async event =>{

    console.log( ' TEST EVENT =>> ',event)
    let msg = 'Hello!'

    if(event.queryStringParameters && event.queryStringParameters.name !== null ) msg = `Hello, ${event.queryStringParameters.name}`

    return {
        statusCode: 200,
        headers:{
            'Content-Type':'application/json'
        },
        body:msg
    }
}