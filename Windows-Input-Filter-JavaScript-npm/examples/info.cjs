const {Interceptor}=require("windows-input-filter");const io=new Interceptor();try{console.log(io.info())}finally{io.close()}
