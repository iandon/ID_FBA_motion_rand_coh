function correctTrial = checkResp(resp, ansResp)
global params;


respIdx = find(resp.key(1) == params.response.allowedRespKeysCodes);


switch resp.check
    case 0
        correctTrial = 2;
    case 1
        correctTrial = ansResp == respIdx;
end


end