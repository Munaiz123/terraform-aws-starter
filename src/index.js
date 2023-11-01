module.exports.handler = async event =>{

    console.log( 'EVENT =>> ', event)
    let msg = 'Hello!'

    if(event.queryStringParameters && event.queryStringParameters.name !== null ) msg = `Hello, ${event.queryStringParameters.name}`

    return {
        status: 201,
        headers:{
            'Content-Type':'application/json'
        },
        body:{
            msg
        }
    }
}